---
-- AUFTRAG: Recovery Tanker
-- 
-- An S-3B Viking tanker stationed at the USS Stennis is assigned to be a recovery tanker.
-- It will orbit overhead the carrier in a race-track pattern at angels 6 at 250 KIAS and
-- updates its pattern as the carrier moves on and/or changes its heading.
-- 
-- At a later time (when the carrier passes a certain waypoint), the default pattern will
-- change to a more general pattern offset of the carriers position.
---

-- Stennis carrier group.
local stennisgroup=NAVYGROUP:New("Stennis Group")
stennisgroup:Activate()

-- Flightgroup.
local tanker=FLIGHTGROUP:New("Recovery Tanker Stennis")

-- Carrier unit.
local Carrier=UNIT:FindByName("USS Stennis")

-- Transport mission.
local mission1=AUFTRAG:NewRECOVERYTANKER(Carrier)

-- Assign mission to the flight group.
tanker:AddMission(mission1)

--- Function called when carrier group passes a waypoint.
function stennisgroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
  local waypoint=Waypoint --Ops.OpsGroup#OPSGROUP.Waypoint
  
  if waypoint.uid==4 then
  
    -- Create a new orbit mission at angels 7, 45° rel heading wrt carrier, 10 NM offset distance to carrier, 90° offset angle of race-track.
    local mission2=AUFTRAG:NewRECOVERYTANKER(Carrier, 7000, 300, 10, 45, 10, 90)
    tanker:AddMission(mission2)
    
    -- Cancel old mission for the new one to take effect.
    mission1:Cancel()
  
  end
end
