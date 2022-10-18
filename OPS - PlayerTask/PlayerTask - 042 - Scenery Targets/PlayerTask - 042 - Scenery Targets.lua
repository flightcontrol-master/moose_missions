-------------------------------------------------------------------------
-- PlayerTask 042 - Caucasus - Test Mission with scenery (map object) targets
-------------------------------------------------------------------------
-- Documentation
-- 
-- PLAYERTASK: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.PlayerTask.html
-- 
-------------------------------------------------------------------------
-- Join the game master slot initially, and then a plane slot after a few
-- seconds, to allow event capturing to start. Tasking is made available
-- over the F10 Menu. 
-- 
-- Join the bombing task "Bomb Bridge". Bridges are near Poti on the map.
-- 
-- Listen to AM 130 or 255 on SRS for messages. Change path below.
-------------------------------------------------------------------------
-- Date: October 2022
-------------------------------------------------------------------------

-- Settings
_SETTINGS:SetPlayerMenuOn()
_SETTINGS:SetImperial()
_SETTINGS:SetA2G_BR()

-- Set up A2G task controller for the blue side named "82nd Airborne"
local taskmanager = PLAYERTASKCONTROLLER:New("82nd Airborne",coalition.side.BLUE,PLAYERTASKCONTROLLER.Type.A2G)

-- Set the menu to be called Eagle Eye
taskmanager:SetMenuName("Eagle Eye")

-- Set up using SRS
local hereSRSPath = "C:\\Program Files\\DCS-SimpleRadio-Standalone" -- location of the SRS installation folder, not the double \
local hereSRSPort = 5002 -- SRS server listening to port 5002

-- Set controller to use radio 130 and 255 AM, female voice, GB english, use "Microsoft Hazel" as voice pack (must be installed on your machine), volume 70%.
taskmanager:SetSRS({130,255},{radio.modulation.AM,radio.modulation.AM},hereSRSPath,"female","en-GB",hereSRSPort,"Microsoft Hazel Desktop",0.7)

-- Controller will announce itself after 60 seconds, on these two broadcast frequencies, when a new player joins
taskmanager:SetSRSBroadcast({127.5,305},{radio.modulation.AM,radio.modulation.AM})

-- create set of zones with the eight bridge component references
local bridges = SET_ZONE:New():FilterPrefixes("Quai"):FilterOnce()
-- build a SET_SCENERY containing the bridges' SCENERY objects
local scenset = SET_SCENERY:New(bridges)
-- create a task
local scenerytask = PLAYERTASK:New(AUFTRAG.Type.BOMBING,scenset,true,2,"Bombing")
-- Menu name of this task
scenerytask:SetMenuName("Bomb bridge")
-- Briefing
scenerytask:AddFreetext("Find and destroy the bridges over the River Quai!")

taskmanager:AddPlayerTaskToQueue(scenerytask)

-- Blow up one bridge component
local scenery = SCENERY:FindByZoneName("Quai-2")

function DestroyBridgeComponent()
  scenery:GetCoordinate():Explosion(500,2)
end

local BridgeTimer=TIMER:New(DestroyBridgeComponent)
BridgeTimer:Start(60)


