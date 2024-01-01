-------------------------------------------------------------------------
-- PlayerTask 042 - Caucasus - Test Mission CTLD and CSAR tasks
-------------------------------------------------------------------------
-- Documentation
-- 
-- PLAYERTASK: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.PlayerTask.html
-- 
-------------------------------------------------------------------------
-- Join the game master slot initially, and then a helicopter slot after a few
-- seconds, to allow event capturing to start. Tasking is made available
-- over the F10 Menu. 
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

-- create a CTLD instance
local myCTLD = CTLD:New(coalition.side.BLUE,{"Air America"},"82nd Transport Wing")
myCTLD:AddCratesCargo("Humvee",{"Humvee"},CTLD_CARGO.Enum.VEHICLE,1,50)
myCTLD:AddTroopsCargo("Platoon",{"Infantry6"},CTLD_CARGO.Enum.TROOPS,6,80)
myCTLD:AddCTLDZoneFromAirbase(AIRBASE.Caucasus.Batumi,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Red,true,false)
myCTLD:AddCTLDZone("CTLD Drop Zone",CTLD.CargoZoneType.DROP,SMOKECOLOR.Green,true,true)
myCTLD.forcehoverload = false
myCTLD:__Start(2)

-- create a CSAR instance
local myCSAR = CSAR:New(coalition.side.BLUE,"Downed Pilot","82nd Transport Wing")
myCSAR.csarPrefix = { "Air America", "helicargo", "MEDEVAC"}
myCSAR.pilotmustopendoors = true 
myCSAR:__Start(2)

-- create a CTLD task and assign it
local newtask = PLAYERTASK:New(AUFTRAG.Type.CTLD,ZONE:FindByName("CTLD Drop Zone"),false,0,"Combat Transport")
newtask:SetSubType("CratesBuild") -- this type name is the FSM event in CTLD we'll need to decide if the build was successful
newtask:SetMenuName("Humvee Transport") -- name for the menu entry
newtask:AddFreetext("Pick up crates for a Humvee and build a Humvee at the CTLD Drop Zone!")
-- Assign
taskmanager:AddPlayerTaskToQueue(newtask) -- add to task controller
myCTLD:AddPlayerTask(newtask) -- add to CTLD instance

-- create two CSAR tasks and assign them - this will be an chained task
local csartask = PLAYERTASK:New(AUFTRAG.Type.CSAR,ZONE:FindByName("CSAR Rescue Zone"),false,0,"Rescue Pilot")
csartask:SetSubType("Boarded") -- this type name is the FSM event in CSAR we'll need to decide the build was successful
csartask:SetMenuName("Rescue Pilot") -- name for the menu entry
csartask:AddFreetext("Pick up the downed pilot 'Moose' from the CSAR Rescue Zone!") -- this will be the text in the Task Info
csartask.CSARPilotName = "Moose" -- this is the pilot we want to save
-- Assign
taskmanager:AddPlayerTaskToQueue(csartask) -- add to task controller
myCSAR:AddPlayerTask(csartask) -- add to CTLD instance

local csartask2 = PLAYERTASK:New(AUFTRAG.Type.CSAR,ZONE:FindByName("CSAR Drop Zone"),false,0,"Deliver Rescued Pilot")
csartask2:SetSubType("Rescued") -- this type name is the FSM event in CSAR we'll need to decide the build was successful
csartask2:SetMenuName("Deliver Rescued Pilot") -- name for the menu entry
csartask2:AddFreetext("Deliver rescued pilots to nearest AFB, FARP or MASH!") -- this will be the text in the Task Info
csartask2.CSARPilotName = "Moose" -- this is the pilot we want to save
-- make this a follow-up task to csartask
csartask:AddNextTaskAfterSuccess(csartask2) -- make csartask2 the task assigned to same pilots when csartask is successfully done
-- assign
taskmanager:AddPlayerTaskToQueue(csartask2) -- add to task controller
myCSAR:AddPlayerTask(csartask2) -- add to CTLD instance

-- drop a pilot in the field after 1 minute
local function Csars()
  myCSAR:SpawnCSARAtZone("CSAR Rescue Zone",coalition.side.BLUE,"Moose",true,false,"Moose",nil,true)
end

local timer=TIMER:New(Csars)
timer:Start(60)




