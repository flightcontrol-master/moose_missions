---------------------------------------------------------------------------------------------------------------------------------------
-- AIRWING: Tanker Wing
-- 
-- Batumi is home of the 931st Air Refueling Wing. The wing consist of two squadrons.
-- The 18th Air Refueling Squadron, who flies KC-135 Stratotankers and the
-- Marine Aerial Refueler Transport Squadron 152 (VMGR-152), nickname "Sumos", who flies KC-130s.
-- 
-- The airwing is responsible for refueling other aircraft in this area. Therefore, it will keep
-- tankers in the air at all times.
-- 
-- Tanker missions are assigned to the airwing for both refueling type system (boom and probe).
-- Once a mission is over because the tanker runs out of fuel (or is shot down), a new mission is assigned.
-- 
-- Another option is to use "patrol points" and set the number of tankers with a specific refueling system.
-- Here, we create an individual patrol point for each refueling system so that pilots better know where to look for their tanker.
-- 
-- Each squadron has a number of dedicated TACAN channels. The assigned tankers will use these on their mission.
-- Once a tanker has returned to its base, the TACAN channel it used will be available again for other aircraft.
-- 
-- NOTE that for demo purposes, we set the low fuel threshold of the aircraft to 90%.
-- When the tanker is low on fuel, it will RTB and a new tanker is spawned.
-- 
---------------------------------------------------------------------------------------------------------------------------------------

--- 
-- Zones
---

local ZoneBoom=ZONE:FindByName("Zone Boom"):DrawZone()
local ZoneProbe=ZONE:FindByName("Zone Probe"):DrawZone()
local ZonePointBoom=ZONE:FindByName("Point Boom"):DrawZone()
local ZonePointProbe=ZONE:FindByName("Point Probe"):DrawZone()

---
-- Squadrons
---

-- KC-135 squadron, callsign "Arco".
local ARS18=SQUADRON:New("KC-135 Template", 5, "18th Air Refueling Squadron") --Ops.Squadron#SQUADRON
ARS18:SetModex(100)
ARS18:SetCallsign(CALLSIGN.Tanker.Arco)
ARS18:SetRadio(260)
ARS18:SetSkill(AI.Skill.EXCELLENT)
ARS18:AddMissionCapability({AUFTRAG.Type.TANKER}, 100)
ARS18:AddTacanChannel(70, 75)

-- KC-130 squadron, callsign "Texaco".
local VMGR152=SQUADRON:New("KC-130 Template", 5, "Marine Aerial Refueler Transport Squadron 152 Sumos") --Ops.Squadron#SQUADRON
VMGR152:SetModex(200)
VMGR152:SetCallsign(CALLSIGN.Tanker.Texaco)
VMGR152:SetRadio(261)
VMGR152:SetSkill(AI.Skill.EXCELLENT)
VMGR152:AddMissionCapability({AUFTRAG.Type.TANKER}, 100)
VMGR152:AddTacanChannel(80, 85)

---  
-- Airwing
---

-- Create an airwing.
local ARW931=AIRWING:New("Warehouse Batumi", "931th Air Refueling Wing") --Ops.AirWing#AIRWING

---
-- Patrol Points
---

-- Add a patrol point for tanker with boom and receptacle.
ARW931:AddPatrolPointTANKER(ZonePointBoom, 20000, 350, 180, 30, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)

-- Add a patrol point for tankers with probe and drogue.
ARW931:AddPatrolPointTANKER(ZonePointProbe, 20000, 350, 0, 30, Unit.RefuelingSystem.PROBE_AND_DROGUE)

-- Set number of tankers constantly in the air.
ARW931:SetNumberTankerBoom(1)
ARW931:SetNumberTankerProbe(1)

---
-- Squadrons
---

-- Add squadrons to airwing.
ARW931:AddSquadron(ARS18)
ARW931:AddSquadron(VMGR152)

---
-- Airwing Payloads
---

-- Not necessary. Tankers (and AWACS) have unlimited payloads.

---
-- Start Airwing
---

-- Start airwing.
ARW931:Start()

---
-- Targets
---

-- None

---
-- Missions
---

-- Function to create a new tanker mission.
local function NewTankerMission(RefuelSystem)

  -- Get coordinate depending on refuel system type.
  local Coordinate
  if RefuelSystem==Unit.RefuelingSystem.BOOM_AND_RECEPTACLE then
    Coordinate=ZoneBoom:GetCoordinate()
  elseif RefuelSystem==Unit.RefuelingSystem.PROBE_AND_DROGUE then
    Coordinate=ZoneProbe:GetCoordinate()
  end

  -- Tanker mission.
  local mission=AUFTRAG:NewTANKER(Coordinate, 20000, 350, 000, 25, RefuelSystem)
  
  -- Assign mission to airwing.
  ARW931:AddMission(mission)
  
  -- Create a new mission when this one is done. Keeps tankers in the air at all times.
  function mission:OnAfterDone()
    MESSAGE:New(string.format("Mission %s done. Creating new TANKER mission for refuel system type %d", mission:GetName(), RefuelSystem), 360):ToAll():ToLog()
    NewTankerMission(RefuelSystem)
  end
  
end

-- Create a tanker mission with boom.
NewTankerMission(Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)

-- Create a tanker mission with probe.
NewTankerMission(Unit.RefuelingSystem.PROBE_AND_DROGUE)


--- Function called each time a flight group goes on a mission. Can be used to fine tune.
function ARW931:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
  local flightgroup=Flightgroup --Ops.FlightGroup#FLIGHTGROUP
  local mission=Mission --Ops.Auftrag#AUFTRAG
  
  -- Get info about TACAN channel.
  local tacanChannel, tacanMorse, tacanBand=flightgroup:GetTACAN()
  
  -- Print some info.
  local text=string.format("Flight %s on %s mission %s. TACAN Channel %s%s (%s)", flightgroup:GetName(), mission:GetType(), mission:GetName(), tostring(tacanChannel), tostring(tacanBand), tostring(tacanMorse))
  MESSAGE:New(text):ToAll():ToLog()  
  
  -- For demo purposes, we set the low fuel threshold to 90%. When the tanker is low on fuel, it will RTB and a new tanker is spawned.
  flightgroup:SetFuelLowThreshold(90)
end


--- Display mission status on screen.
local function MissionStatus()

  local text="Missions:"
  for _,_mission in pairs(ARW931.missionqueue) do
    local m=_mission --Ops.Auftrag#AUFTRAG
    text=text..string.format("\n- %s %s %s*%d/%d [%d %%]  (%s*%d/%d)", 
    m:GetName(), m:GetState():upper(), m:GetTargetName(), m:CountMissionTargets(), m:GetTargetInitialNumber(), m:GetTargetDamage(), m:GetType(), m:CountOpsGroups(), m:GetNumberOfRequiredAssets())
  end
  
  -- Payloads
  text=text.."\n\nPayloads:"  
  for _,aname in pairs(AUFTRAG.Type) do
    local n=ARW931:CountPayloadsInStock({aname})
    if n>0 then
      text=text..string.format("\n%s %d", aname, n)
    end
  end
    
  -- Info message to all.
  MESSAGE:New(text, 25):ToAll()
end

-- Display primary and secondary mission status every 60 seconds.
TIMER:New(MissionStatus):Start(5, 30)
