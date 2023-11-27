-------------------------------------------------------------------------
-- L16-001 - Datalink Info From AI
-------------------------------------------------------------------------
-- Documentation
-- 
-- GROUP: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Wrapper.Group.html
-- 
-- Note: As of today, Link16 info can be obtained from F-16, F-18, F-15E (not the user flyable one) and A-10C-II.
--
-------------------------------------------------------------------------
-- Join the F-16. Use the F-10 menu to obtain and then add the Link16
-- STNs in your plane's DED. Don't forget to switch on your datalink
-- and set it to transmit.
-------------------------------------------------------------------------
-- Date: 27 Nov 2023
-------------------------------------------------------------------------

-- Spawn a 4-ship F-18
local F18s = SPAWN:NewWithAlias("Aerial-1","F-18")
:InitGrouping(4)
:InitRandomizeCallsign()
:Spawn()

-- Spawn a 2-ship F-16
local F16s = SPAWN:NewWithAlias("Aerial-2","F-16")
:InitGrouping(2)
:InitRandomizeCallsign()
:OnSpawnGroup(
  function(grp)
    local FG = FLIGHTGROUP:New(grp)
    FG:SetDetection(true)
    FG:SetEngageDetectedOn(75)
    local mission = AUFTRAG:NewINTERCEPT(GROUP:FindByName("Aerial-3"))
    mission:SetMissionAltitude(25000)
    mission:SetMissionSpeed(400)
    mission:SetMissionRange(150)
    mission:SetVerbosity(2)
    mission:SetEngageAsGroup(true)
    --mission:SetMissionWaypointCoord(ZONE:New("Waypoint 1"):GetCoordinate(UTILS.FeetToMeters(25000)))
    FG:AddMission(mission)
  end
)
:Spawn()

-- Function to print the info on the screen
function ListLink16ForGroups(Filter)
  local set = SET_GROUP:New():FilterPrefixes(Filter):FilterCoalitions("blue"):FilterOnce()
  if set:CountAlive() > 0 then
  set:ForEach(
    function(grp)
      local group = grp -- Wrapper.Group#GROUP
      if group and group:IsAlive() then
        local table, report = group:GetGroupSTN()
        MESSAGE:New(report,20):ToBlue()
      end
    end
  )
  else
    MESSAGE:New("No matching groups!",20):ToBlue()
  end
end

-- Menus
local mainmenu = MENU_COALITION:New(coalition.side.BLUE,"STN Data")
local subF16 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"F-16s",mainmenu,ListLink16ForGroups,"F.16")
local subF16 = MENU_COALITION_COMMAND:New(coalition.side.BLUE,"F-18s",mainmenu,ListLink16ForGroups,"F.18")