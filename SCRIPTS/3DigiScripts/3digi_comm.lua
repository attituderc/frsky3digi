-- 3Digi Sensor ID for integration
local THREEDIGI_INTEGRATION_SENSOR_ID  = 0x0D

-- 3Digi Sensor ID for telemetry
local THREEDIGI_TELEMETRY_SENSOR_ID = 0x1B

local FRSKY_FRAME_DATA = 0x10
local FRSKY_FRAME_CONFIG_READ = 0x30
local FRSKY_FRAME_CONFIG_WRITE = 0x31
local FRSKY_FRAME_CONFIG_RESPONSE = 0x32

-- Local functions
local TDSendBuffer, TDReceiveBuffer, TDReceiveBufferClear
local DebugPrint

-- Returns true if request could be sent or nil on error
function TDReadVarsWithBitIndexStart(Var1Id, Var1BitIndex, Var2Id, Var2BitIndex)
	local sendBuffer = {}

	sendBuffer[1] = bit32.band(Var1BitIndex, 0xFF)
	sendBuffer[2] = bit32.band(Var2BitIndex, 0xFF)
	
	sendBuffer[3] = bit32.band(bit32.rshift(Var1Id, 8), 0xFF)
	sendBuffer[4] = bit32.band(bit32.rshift(Var1Id, 0), 0xFF)
	
	sendBuffer[5] = bit32.band(bit32.rshift(Var2Id, 8), 0xFF)
	sendBuffer[6] = bit32.band(bit32.rshift(Var2Id, 0), 0xFF)

   -- Send request
   TDReceiveBufferClear()
	local ret = TDSendBuffer(THREEDIGI_INTEGRATION_SENSOR_ID, FRSKY_FRAME_CONFIG_READ, sendBuffer)
	if ret == nil or ret == false then
		DebugPrint("SendBuffer fail")
	   return nil
	end
	
	return true
end

-- Returns true if request could be sent or nil on error
function TDReadVarsStart(Var1Id, Var2Id)
   return TDReadVarsWithBitIndexStart(Var1Id, -1, Var2Id, -1)
end

-- Returns value1, value2 if read was ok nil on error or if there was no received data
function TDReadVarsGetAnswer()
	-- Get answer for previous request
	local receiveBuffer = TDReceiveBuffer(THREEDIGI_TELEMETRY_SENSOR_ID, FRSKY_FRAME_CONFIG_RESPONSE)
	if receiveBuffer ~= nil then
		-- check errno
		local errNo = receiveBuffer[1]
		if errNo ~= 0 then
			DebugPrint("errno = " .. errNo)
			return nil
		end
		
		--- Extract values
		local value1 =  bit32.lshift(receiveBuffer[3], 8) + receiveBuffer[4];
		local value2 =  bit32.lshift(receiveBuffer[5], 8) + receiveBuffer[6];

		return value1, value2
	end
	
	return nil
end

-- Returns true if request could be sent or nil on error
function TDWriteVarWithBitIndexStart(VarId, VarBitIndex, Value)
	local sendBuffer = {}

	sendBuffer[1] = bit32.band(VarBitIndex, 0xFF)
	sendBuffer[2] = 0
	
	sendBuffer[3] = bit32.band(bit32.rshift(VarId, 8), 0xFF)
	sendBuffer[4] = bit32.band(bit32.rshift(VarId, 0), 0xFF)
	
	sendBuffer[5] = bit32.band(bit32.rshift(Value, 8), 0xFF)
	sendBuffer[6] = bit32.band(bit32.rshift(Value, 0), 0xFF)

   -- Send request
   TDReceiveBufferClear()
	local ret = TDSendBuffer(THREEDIGI_INTEGRATION_SENSOR_ID, FRSKY_FRAME_CONFIG_WRITE, sendBuffer)
	if ret == nil or ret == false then
		DebugPrint("SendBuffer fail")
	   return nil
	end
	
	return true
		
end

function TDWriteVarStart(VarId, Value)
   return TDWriteVarWithBitIndexStart(VarId, -1, Value)
end

-- Returns the value of the written var or nil on error
function TDWriteVarGetAnswer(VarId, Value)
	-- Get answer for previous request
   local receiveBuffer = TDReceiveBuffer(THREEDIGI_TELEMETRY_SENSOR_ID, FRSKY_FRAME_CONFIG_RESPONSE)
   if receiveBuffer ~= nil then
      -- check errno
      local errNo = receiveBuffer[1]
      if errNo ~= 0 then
         DebugPrint("errno = " .. errNo)
         return nil
      end
      
      --- Extract values
      local writtenValue = bit32.lshift(receiveBuffer[3], 8) + receiveBuffer[4];
      local writtenVarId = bit32.lshift(receiveBuffer[5], 8) + receiveBuffer[6];
         
      if (VarId == nil or writtenVarId == VarId) 
			and (Value == nil or writtenValue == Value) then
         DebugPrint("Returning value")
         return Value
      else
         DebugPrint("Values not same")
         return nil
      end
   end
	
	return nil
		
end


function TDSendBuffer(SensorId, FrameId, SendBuffer)
	if SendBuffer == nil or #SendBuffer ~= 6 then
		DebugPrint("SendBuffer size wrong")
		return nil
	end

	local sendDataId = 0
   sendDataId = bit32.lshift(bit32.band(SendBuffer[1], 0xFF), 0) 
		+ bit32.lshift(bit32.band(SendBuffer[2], 0xFF), 8)

   sendValue = bit32.lshift(bit32.band(SendBuffer[3], 0xFF), 0)
	   + bit32.lshift(bit32.band(SendBuffer[4], 0xFF), 8)
	   + bit32.lshift(bit32.band(SendBuffer[5], 0xFF), 16)
	   + bit32.lshift(bit32.band(SendBuffer[6], 0xFF), 24)

   -- Send request
	local ret = sportTelemetryPush(SensorId, FrameId, sendDataId, sendValue)

	return ret
end

function TDReceiveBuffer(SensorId, FrameId)
   local readBuffer = {}

	-- Get answer
   local receivedSensorId, receivedFrameId, receivedDataId, receivedValue = sportTelemetryPop()
   if receivedSensorId ~= nil then
      if receivedSensorId == SensorId and receivedFrameId == FrameId then
         DebugPrint("Data received");
         -- Extract data
         readBuffer[1] = bit32.band(bit32.rshift(receivedDataId, 0), 0xFF)
         readBuffer[2] = bit32.band(bit32.rshift(receivedDataId, 8), 0xFF)
         
         readBuffer[3] = bit32.band(bit32.rshift(receivedValue, 0), 0xFF)
         readBuffer[4] = bit32.band(bit32.rshift(receivedValue, 8), 0xFF)
         readBuffer[5] = bit32.band(bit32.rshift(receivedValue, 16), 0xFF)
         readBuffer[6] = bit32.band(bit32.rshift(receivedValue, 24), 0xFF)

         return readBuffer
      else
         DebugPrint("Wrong sensor ID received");
         return nil
      end
   end
   
	return nil
end

function TDReceiveBufferClear()
   sportTelemetryPop()
end
   
function DebugPrint(Text)
	local line = 8
   lcd.drawText(1, (line - 1) * 8, string.rep(" ", 40))
	lcd.drawText(1, (line - 1) * 8, Text)
end
