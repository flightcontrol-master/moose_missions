---
-- AUFTRAG: Freighttransport Plane
-- 
-- A C-130J is tasked to transport cargo from Krasnodar to Krymsk.
-- The aircraft will load four ammo boxes into its internal storage.
-- 
-- These ammo boxes have to be within a 40 m radius from the plane
-- before the mission can start.
-- 
-- The mission is successful if at least one cargo item makes it
-- to its destination airbase.
---

-- Create a FLIGHTGROUP object of the C-130
local c130=FLIGHTGROUP:New("C-130 Krasnodar")

-- Define the set of cargo that we want to tansport
local cargoset=SET_STATIC:New()
cargoset:FilterPrefixes("Cargo C-130 Krasnodar")
cargoset:FilterOnce()

-- Create a mission to transport the cargo to Krymsk airbase
local mission=AUFTRAG:NewFREIGHTTRANSPORT(cargoset, AIRBASE:FindByName(AIRBASE.Caucasus.Krymsk))
  
-- Assign mission to C-130
c130:AddMission(mission)

-- Do something with the cargo, once it has been delivered
function mission:OnAfterSuccess(From, Event, To)

  local cargoset=mission:GetCargoSet()
  
  local function smoke(_static)
    local static=_static --Wrapper.Static#STATIC
    static:SmokeBlue()
  end
  
  cargoset:ForEach(smoke)

end
