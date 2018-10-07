assert(loadScript("/SCRIPTS/3DigiScripts/3digi_comm.lua"))()

local THREEDIGI_REQUEST_TIMEOUT_MS = 1000
local RequestStartTimestamp = 0
local RequestActive = false

-- TestVars
VARID_PS1_AIL_P = 1128
VARID_PS2_AIL_P = 2128

local TestRunning = false
local Counter = 0

local timeCurr = 0
local timeSum = 0
local timeMin = 0
local timeMax = 0
local timeAvg = 0

-- Local functions
local DebugPrint

local function init_func()
end

local function backgound_func()
end

local function run_func(event)
   lcd.clear()
   DrawText(1, "SmartPort Speedtest")
   DrawText(2, "+ start test, - stop test")
   DrawText(4, "Time (ms): Curr: "..timeCurr.."; Avg: "..string.format("%.0f", timeAvg))
   DrawText(5, "           Min: "..timeMin.."; Max: "..timeMax)
   DrawText(6, "Count: "..Counter)
	
	--DrawText(6, "Key: "..event)
	local currentEvent = event
   
   if RequestActive then
      -- Check timeout
      local now = getTime() -- Resolution 10ms
      if RequestStartTimestamp + (THREEDIGI_REQUEST_TIMEOUT_MS / 10) < now then
         -- timeout
         RequestActive = false
         DebugPrint("Timeout")
      end
   end

	if TestRunning then
		if not RequestActive then
         DebugPrint("TDReadVarsStart()")
         local ret = TDReadVarsStart(VARID_PS1_AIL_P, VARID_PS2_AIL_P)
         if ret ~= true then
            DebugPrint("TDReadVarsStart() error")
         end
         RequestStartTimestamp = getTime()
         RequestActive = true
		else
			-- Get answer from previous request
         DebugPrint("TDReadVarsGetAnswer()")
         local var1, var2 = TDReadVarsGetAnswer()
         if var1 ~= nil then
            RequestActive = false
				Counter = Counter + 1
            timeCurr = ((getTime() - RequestStartTimestamp) * 10)
            if timeMin == 0 or timeCurr < timeMin then
               timeMin = timeCurr
            end
            if timeCurr > timeMax then
               timeMax = timeCurr
            end
            timeSum = timeSum + timeCurr
            timeAvg = timeSum / Counter
            DrawText(4, "Time (ms): Curr: "..timeCurr.."; Avg: "..string.format("%.0f", timeAvg))
            DrawText(5, "           Min: "..timeMin.."; Max: "..timeMax)
				DrawText(6, "Count: "..Counter)
         end
      end
	end
	
   
   -- navigation
   if currentEvent == EVT_MENU_LONG then -- Taranis QX7 / X9
   elseif currentEvent == EVT_MENU_BREAK then -- Taranis QX7 / X9
   elseif currentEvent == EVT_ENTER_LONG then -- Horus
   elseif currentEvent == EVT_EXIT_BREAK then
   elseif currentEvent == EVT_PLUS_BREAK or currentEvent == EVT_ROT_RIGHT then
	   Counter = 0
      timeCurr = 0
      timeSum = 0
      timeMin = 0
      timeMax = 0
      timeAvg = 0
	   TestRunning = true
   elseif currentEvent == EVT_MINUS_BREAK or currentEvent == EVT_ROT_LEFT then
	   TestRunning = false
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
