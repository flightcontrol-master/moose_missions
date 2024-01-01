---------------------------------------------------------------------------------------------------------------------------------------
-- AIRWING: Bomber Wing
-- 
-- Kutaisi is the home of the 5th Bomb Wing. The wing consists of one squadron.
-- That is the 23d Bomb Squadron ("Panthers Barons") equipped with B-52s.
-- 
-- The wing gets five assignments:
-- 1.) Bomb a group at the old airfield near Kobuleti (BOMBING).
-- 2.) Bomb the runway at Beslan (BOMBRUNWAY).
-- 3.) Attack enemy ships (ANTISHIP)
-- 4.) Attack an SA-10 site near Mozdok (SEAD).
-- 5.) Bomb parking spots at Nalchik (BOMBCARPET).
-- 
-- The wing has special payloads for each of these mission types available.
---------------------------------------------------------------------------------------------------------------------------------------

-- Zones we need later on.
local zoneAlpha=ZONE:FindByName("Alpha"):DrawZone()
local zoneBravo=ZONE:FindByName("Bravo"):DrawZone()
local zoneNalchik=ZONE:FindByName("Nalchik Airbase Parking"):DrawZone()

---
-- Define Squadron(s)
---

-- Squadron of ten B-52H two ships.
local BS23=SQUADRON:New("B-52 Template", 10, "23d Bomb Squadron") --Ops.Squadron#SQUADRON
BS23:SetGrouping(2)                      -- Two-ships. Good to have a wingmen.
BS23:SetMissionRange(300)                -- Missions up to 300 NM can be executed.
BS23:SetModex(500)                       -- Onboard numbers are 500, 501, ...
BS23:SetCallsign(CALLSIGN.Aircraft.Ford) -- Call sign is Ford.
BS23:SetRadio(260)                       -- Squadon communicates on 260 MHz AM.
BS23:SetSkill(AI.Skill.EXCELLENT)        -- These guy are really good.
BS23:AddMissionCapability({AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY, AUFTRAG.Type.BOMBCARPET}, 90) --Highly specialized in bombing stuff.
BS23:AddMissionCapability({AUFTRAG.Type.ANTISHIP, AUFTRAG.Type.SEAD}, 70)                               --Also good at anti ship and SEAD with the right payload.

---  
-- Define Airwing
---

-- Create an airwing.
local BW5=AIRWING:New("Warehouse Kutaisi", "5th Bomb Wing") --Ops.AirWing#AIRWING

--- Function called each time a flight group goes on a mission. Can be used to fine tune.
function BW5:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
  local flightgroup=Flightgroup --Ops.FlightGroup#FLIGHTGROUP
  local mission=Mission --Ops.Auftrag#AUFTRAG
  
  -- Print some info.
  local text=string.format("Flight %s on %s mission %s", flightgroup:GetName(), mission:GetType(), mission:GetName())
  MESSAGE:New(text):ToAll()
  env.info(text)
end

-- Add squadron(s) to airwing.
BW5:AddSquadron(BS23)

---
-- Airwing Payloads
---

-- Payloads available.
BW5:NewPayload("B-52 Payload AGM-84A*8",  10, {AUFTRAG.Type.ANTISHIP}, 100)
BW5:NewPayload("B-52 Payload AGM-86C*20", 10, {AUFTRAG.Type.SEAD}, 100)
BW5:NewPayload("B-52 Payload Mk 82*51",   10, {AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY, AUFTRAG.Type.BOMBCARPET}, 80)
BW5:NewPayload("B-52 Payload Mk-84*18",   10, {AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY, AUFTRAG.Type.BOMBCARPET}, 80)
BW5:NewPayload("B-52 Payload Mk20*18",    10, {AUFTRAG.Type.BOMBING, AUFTRAG.Type.BOMBRUNWAY, AUFTRAG.Type.BOMBCARPET}, 80)

---
-- Start Airwing
---

-- Start airwing.
BW5:Start()

---
-- Define Targets
---

-- Practice target consising of 5 fire trucks located at the old airfield near Kobuleti forming an X.
local targetX=TARGET:New(GROUP:FindByName("Red Target X-1"))
local targetNaval=TARGET:New(GROUP:FindByName("Red Naval Target"))
local targetBeslan=TARGET:New(AIRBASE:FindByName("Beslan"))
local targetSA10=TARGET:New(GROUP:FindByName("SA-10 Mozdok"))
local targetNalchik=TARGET:New(zoneNalchik)

---
-- Define Missions
---

-- Bombing mission on target X at 20,000 ft. Mission (ingress) waypoint is in zone Alpha while egress is over zone Bravo. Push time is at 0930 hours. 
local missionBombing=AUFTRAG:NewBOMBING(targetX, 20000)
missionBombing:SetMissionWaypointCoord(zoneAlpha):SetMissionAltitude(20000)
missionBombing:SetMissionEgressCoord(zoneBravo, 15000)
missionBombing:SetPushTime("9:30")

-- Anti-ship mission.
local missionAntiShip=AUFTRAG:NewANTISHIP(targetNaval, 20000)

-- Bomb runway of Beslan.
local missionRunway=AUFTRAG:NewBOMBRUNWAY(targetBeslan, 25000)

-- Carpet bomb Nalchik.
local missionCarpet=AUFTRAG:NewBOMBCARPET(targetNalchik, 25000, 250)

-- SEAD mission at SA-10 near Mozdok.
local missionSEAD=AUFTRAG:NewSEAD(targetSA10, 25000)

-- Mission e-gress is to zone Alpha at 20,000 ft.
missionSEAD:SetMissionEgressCoord(zoneAlpha, 20000)


-- Assign mission to airwing.
BW5:AddMission(missionBombing)
BW5:AddMission(missionCarpet)
BW5:AddMission(missionRunway)
BW5:AddMission(missionAntiShip)
BW5:AddMission(missionSEAD)


---
-- Misc
---

--- Display mission status on screen.
local function MissionStatus()

  local text="Missions:"
  for _,_mission in pairs(BW5.missionqueue) do
    local m=_mission --Ops.Auftrag#AUFTRAG
    text=text..string.format("\n- %s %s %s*%d/%d [%d %%]  (%s*%d/%d)", 
    m:GetName(), m:GetState():upper(), m:GetTargetName(), m:CountMissionTargets(), m:GetTargetInitialNumber(), m:GetTargetDamage(), m:GetType(), m:CountOpsGroups(), m:GetNumberOfRequiredAssets())
  end
  
  -- Payloads
  text=text.."\n\nAvailable Payloads:"  
  for _,aname in pairs(AUFTRAG.Type) do
    local n=BW5:CountPayloadsInStock({aname})
    if n>0 then
      text=text..string.format("\n%s %d", aname, n)
    end
  end
    
  -- Info message to all.
  MESSAGE:New(text, 25):ToAll()
end

-- Display primary and secondary mission status every 60 seconds.
TIMER:New(MissionStatus):Start(5, 30)
