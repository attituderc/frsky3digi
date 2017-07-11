SetupPages = {
   {
      title = "Information -simple",
      text = {
         { t = "Firmware",      x =  25,  y = 16 },
         { t = "App Ver.",      x = 25,  y = 26 },
         { t = "Last Err",      x = 25,  y = 36 },
         { t = "Flight",   x =  25,  y = 46 },
         { t = "Message",  x =  25,  y = 56 },
      },
      fields = {
         -- Firmware
         { x =  100, y = 16, i =  1 },
         -- App Ver.
         { x =  100, y = 26, i =  2 },
         -- Last Err
         { x = 100, y = 36, i =  3 },
		 -- Flight
         { x = 100, y = 46, i =  5 },
		 -- Message
         { x = 100, y = 56, i =  9 },
      },
   },
   {
      title = "Presets Agility  -simple",
      text = {
         { t = "Param 1",      x =  25,  y = 16 },
         { t = "Param 2",      x = 25,  y = 26 },
         { t = "Param 3",      x = 25,  y = 36 },
      },
      fields = {
         -- Param 1
         { x =  100, y = 16, i =  1 },
         -- Param 2
         { x =  100, y = 26, i =  2 },
         -- Param 3
         { x = 100, y = 36, i =  3 },
      },
   },
   {
      title = "Presets Model Size -simple",
      text = {
         { t = "Param 1",      x =  25,  y = 16 },
         { t = "Param 2",      x = 25,  y = 26 },
         { t = "Param 3",      x = 25,  y = 36 },
      },
      fields = {
         -- Param 1
         { x =  100, y = 16, i =  1 },
         -- Param 2
         { x =  100, y = 26, i =  2 },
         -- Param 3
         { x = 100, y = 36, i =  3 },
      },
   },
   {
      title = "Param Set 1 -simple",
      text = {
         { t = "Agility",      x =  25,  y = 16 },
         { t = "Overall gain",      x = 25,  y = 26 },
      },
      fields = {
         -- Param 1
         { x =  100, y = 16, i =  1 },
         -- Param 2
         { x =  100, y = 26, i =  2 },
      },
   },
   {
      title = "Param Set 2 -simple",
      text = {
         { t = "Agility",      x =  25,  y = 16 },
         { t = "Overall gain",      x = 25,  y = 26 },
      },
      fields = {
         -- Param 1
         { x =  100, y = 16, i =  1 },
         -- Param 2
         { x =  100, y = 26, i =  2 },
      },
   },
   {
      title = "Param Set 3 -simple",
      text = {
         { t = "Agility",      x =  25,  y = 16 },
         { t = "Overall gain",      x = 25,  y = 26 },
      },
      fields = {
         -- Param 1
         { x =  100, y = 16, i =  1 },
         -- Param 2
         { x =  100, y = 26, i =  2 },
      },
   },
   {
      title = "Live Data -simple",
      text = {
         { t = "P",      x =  72,  y = 14 },
         { t = "I",      x = 100,  y = 14 },
         { t = "D",      x = 128,  y = 14 },
         { t = "ROLL",   x =  25,  y = 26 },
         { t = "PITCH",  x =  25,  y = 36 },
         { t = "YAW",    x =  25,  y = 46 },
      },
      fields = {
         -- P
         { x =  66, y = 26, i =  1 },
         { x =  66, y = 36, i =  4 },
         { x =  66, y = 46, i =  7 },
         -- I
         { x =  94, y = 26, i =  2 },
         { x =  94, y = 36, i =  5 },
         { x =  94, y = 46, i =  8 },
         -- D
         { x = 122, y = 26, i =  3 },
         { x = 122, y = 36, i =  6 },
         --{ x = 122, y = 46, i =  9 },
      },
   },
}

MenuBox = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 122, 55, "No Telemetry", BLINK }

local run_ui = assert(loadScript("3digiui.lua"))()
return {run=run_ui}
