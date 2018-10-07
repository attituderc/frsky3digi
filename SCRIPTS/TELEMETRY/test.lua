assert(loadScript("/SCRIPTS/3DigiScripts/3digi_comm.lua"))()

local THREEDIGI_REQUEST_TIMEOUT_MS = 1000
local RequestStartTimestamp = 0
local RequestLastEvent = 0

local RequestWriteVarId = 0
local RequestWriteNewValue = 0

-- TestVars
VARID_PS1_AIL_P = 1128
Ps1AilP = 0
VARID_PS2_AIL_P = 2128
Ps2AilP = 0

counter = 0
local FirstRun = true

-- Local functions
local DebugPrint

local function init_func()
end

local function backgound_func()
end

local function run_func(event)
	if FirstRun == true then
	   lcd.clear()
      DrawText(1, "3Digi Smartport Test")
		FirstRun = false
	end
	
	--DrawText(6, "Key: "..event)
	local currentEvent = event
   
   if RequestLastEvent ~= 0 then
      -- Check timeout
      local now = getTime() -- Resolution 10ms
      if RequestStartTimestamp + (THREEDIGI_REQUEST_TIMEOUT_MS / 10) < now then
         -- timeout
         RequestLastEvent = 0
         DebugPrint("Timeout")
      else
         -- Continue with last event
         currentEvent = RequestLastEvent
      end
   end
   
   -- navigation
   if currentEvent == EVT_MENU_LONG then -- Taranis QX7 / X9
   elseif currentEvent == EVT_MENU_BREAK then -- Taranis QX7 / X9
		lcd.clear()
      DrawText(1, "3Digi Smartport Test")
		if RequestLastEvent == 0 then
         DebugPrint("TDReadVarsStart()")
         local ret = TDReadVarsStart(VARID_PS1_AIL_P, VARID_PS2_AIL_P)
         if ret ~= true then
            DebugPrint("TDReadVarsStart() error")
         end
         RequestStartTimestamp = getTime()
         RequestLastEvent = currentEvent
         counter= 0
		else
			-- Get answer from previous request
         counter = counter + 1
         DebugPrint("TDReadVarsGetAnswer()")
         local var1, var2 = TDReadVarsGetAnswer()
         if var1 ~= nil then
				Ps1AilP = var1
				Ps2AilP = var2
            DrawText(2, "Ps1AilP = "..string.format("%3d", Ps1AilP))
            DrawText(3, "Ps2AilP = "..string.format("%3d", Ps2AilP))
            RequestLastEvent = 0
            DrawText(4, ((getTime() - RequestStartTimestamp) * 10).."ms")
         end
      end
   elseif currentEvent == EVT_ENTER_LONG then -- Horus
   elseif currentEvent == EVT_EXIT_BREAK then
   elseif currentEvent == EVT_PLUS_BREAK or currentEvent == EVT_ROT_RIGHT
		or currentEvent == EVT_MINUS_BREAK or currentEvent == EVT_ROT_LEFT then
		-- Change Ps1AilP as test
      if RequestLastEvent == 0 then
         DebugPrint("TDWriteVarStart()")
			local ret
			RequestWriteVarId = VARID_PS1_AIL_P
			if currentEvent == EVT_PLUS_BREAK or currentEvent == EVT_ROT_RIGHT then
				RequestWriteNewValue = Ps1AilP + 1
			else
				RequestWriteNewValue = Ps1AilP - 1
			end
			ret = TDWriteVarStart(RequestWriteVarId, RequestWriteNewValue)
         if ret ~= true then
            DebugPrint("TDWriteVarStart() error")
         end
         RequestStartTimestamp = getTime()
         RequestLastEvent = currentEvent
		else
			-- Get answer from previous request
         DebugPrint("TDReadVarsGetAnswer()")
         local var = TDWriteVarGetAnswer(RequestWriteVarId, RequestWriteNewValue)
         if var ~= nil then
			   Ps1AilP = var
            DrawText(2, "Ps1AilP = "..string.format("%3d", Ps1AilP))
            RequestLastEvent = 0
            DrawText(4, ((getTime() - RequestStartTimestamp) * 10).."ms")
         end
      end
   --elseif currentEvent == EVT_MINUS_BREAK or currentEvent == EVT_ROT_LEFT then
   elseif currentEvent == EVT_ENTER_BREAK then
   elseif currentEvent == EVT_PAGEUP_FIRST then
   elseif currentEvent == EVT_PAGEDN_FIRST then
   end

   return 0
end

function DrawText(Line, Text)
	lcd.drawText(1, (Line - 1) * 8, Text)
end

function DebugPrint(Text)
	local line = 7
	lcd.drawText(1, (line - 1) * 8, string.rep(" ", 40))
	lcd.drawText(1, (line - 1) * 8, Text)
end

return {run=run_func, background=backgound_func, init=init_func}
