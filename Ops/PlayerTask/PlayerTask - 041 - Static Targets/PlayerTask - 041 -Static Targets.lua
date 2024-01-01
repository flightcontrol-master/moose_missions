-------------------------------------------------------------------------
-- PlayerTask 041 - Caucasus - Test Mission with static targets
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
-- Join one of bombing tasks. 
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

-- Add a static as a target - here, a TV Tower
local target = STATIC:FindByName("Radiotower")
local newtask2 = PLAYERTASK:New(AUFTRAG.Type.BOMBING,target,true,3,"Bombing")
-- Briefing
newtask2:AddFreetext("Find and neutralize the TV tower!")
-- Menu name of this task
newtask2:SetMenuName("Neutralize TV Tower")

-- add custom success function - if the tower is dead or lost 80% of its lifepoints, we're done.
newtask2:AddConditionSuccess(
  function(static)
    if (not static) or static:GetLife() < 1 or static:GetLife() < 0.2* static:GetLife0() then
      return true
    else
      return false
    end
  end, target
)
taskmanager:AddPlayerTaskToQueue(newtask2)

-- auto-add map markers when tasks are added
function taskmanager:OnAfterTaskAdded(From,Event,To,Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  local coord = task.Target:GetCoordinate()
  local taskID = string.format("Task ID #%03d | Type: %s | Threat: %d",task.PlayerTaskNr,task.Type,task.Target:GetThreatLevelMax())
  local mark = MARKER:New(coord,taskID)
  mark:ReadWrite()
  mark:ToCoalition(taskmanager.Coalition)
end

