---
-- CHIEF: Capture Zone
-- 
-- The blue chief controls a brigade located at Kobuleti and an airwing
-- located at Kutaisi.
-- 
-- The brigade consists of four platoons:
-- * Infantry for ground attack and on guard missions
-- * APCs of type Fuchs for troop transport missions
-- * IFVs of type Marder for ground attack and transport missions
-- * MBTs of type Leo 2 for ground attack and on guard missions
-- 
-- The airwing consists of three squadrons:
-- * F-16CMs for intercept missions (not used here)
-- * A-10Cs for BAI and CAS missions
-- * UH-1Hs for OPSTRANSPORT missions.
--
-- We received intel that enemy forces are approaching from the South
-- who want to capture and possibly destroy the strategically important bridge.
-- 
-- We define a zone South of the bridge as strategic zone. As the zone is currently
-- empty the chief will send ground troops to effectively capture it.
-- 
-- Rather than the default response for an empty zone, we define the "resources" to 
-- be employed by hand. We will send
-- * IFVs (up to three) to patrol the zone
-- * Infantry (up to three), which are transported via helicopters
-- * Infantry (up to three), which are transported via APCs
-- 
-- The transport helicopters are recruited from Kutaisi, whilst the APCs are locally
-- available at Kobuleti.
---

---
-- OPSZONE
-- Define opszone(s) that will become the strategic zones that the chief will capture.
-- The chief will start the zones when they are added.
---

local OpsZoneKobuletiBridgeAlpha=OPSZONE:New("Kobuleti Bridge Alpha") --Ops.OpsZone#OPSZONE

---
-- BRIGADE Kobuleti
---

-- Platoon infantry (five 7 groups of 5 soldiers each).
local Platoon1=PLATOON:New("Infantry M4 Template", 10, "Platoon Infantry M4 Alpha")
Platoon1:SetGrouping(5)
Platoon1:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK, AUFTRAG.Type.ONGUARD}, 70)

-- Platoon of Transportpanzer Fuchs APCs capable of transport missions.
local Platoon2=PLATOON:New("TPz Fuchs Template", 3, "Platoon APC Fuchs Alpha")
Platoon2:AddMissionCapability({AUFTRAG.Type.OPSTRANSPORT}, 70)

-- Platoon of Transportpanzer Fuchs APCs capable of transport missions.
local Platoon3=PLATOON:New("IFV Marder Template", 3, "Platoon IFV Marder Alpha")
Platoon3:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK, AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ONGUARD}, 80)

-- Platoon of Leopard 2 tanks capable of GROUNDATTACK and ONGUARD missions.
local Platoon4=PLATOON:New("MBT Leopard-2A6M Template", 1, "Platoon Leopard Alpha")
Platoon4:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK, AUFTRAG.Type.ONGUARD}, 90)

-- Brigade at Kobuleti
local BrigadeKobuleti=BRIGADE:New("Warehouse Kobuleti", "Brigade Kobuleti") --Ops.Brigade#BRIGADE
BrigadeKobuleti:SetSpawnZone(ZONE:New("Kobuleti Spawn"))

-- Add platoon(s) to brigade.
BrigadeKobuleti:AddPlatoon(Platoon1)
BrigadeKobuleti:AddPlatoon(Platoon2)
BrigadeKobuleti:AddPlatoon(Platoon3)
BrigadeKobuleti:AddPlatoon(Platoon4)

---
-- AIRWING Kutaisi
---

-- F-16 Fighter Squadron.
local SquadFSQ13=SQUADRON:New("F-16CM Template", 5, "13th Fighter Squadron") --Ops.Squadron#SQUADRON
SquadFSQ13:SetGrouping(1) -- One aircraft per group.
SquadFSQ13:SetModex(130)  -- Tail number of the sqaud start with 130, 131,...
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 90) -- Squad can do intercept missions.
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.ALERT5})        -- Squad can be spawned at the airfield in uncontrolled state.
SquadFSQ13:SetMissionRange(200) -- Squad will be considered for targets within 200 NM of its airwing location.

-- A-10C Fighter Squadron.
local SquadFSQ14=SQUADRON:New("A-10C Template", 5, "14th Fighter Squadron") --Ops.Squadron#SQUADRON
SquadFSQ14:SetGrouping(1) -- One aircraft per group.
SquadFSQ14:SetModex(140)  -- Tail number of the sqaud start with 140, 141,...
SquadFSQ14:AddMissionCapability({AUFTRAG.Type.BAI, AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED}, 90) -- Squad can do BAI and CAS missions
SquadFSQ14:AddMissionCapability({AUFTRAG.Type.ALERT5})        -- Squad can be spawned at the airfield in uncontrolled state.
SquadFSQ14:SetMissionRange(200) -- Squad will be considered for targets within 200 NM of its airwing location.

-- UH-1H Transport Squadron.
local SquadHTS01=SQUADRON:New("UH-1H Template", 5, "1st Helo Transport Squadron") --Ops.Squadron#SQUADRON
SquadHTS01:SetAttribute(GROUP.Attribute.AIR_TRANSPORTHELO) --DCS qualifies this as an attack helo, but we want to set it to be a transport helo.
SquadHTS01:SetGrouping(1)
SquadHTS01:SetModex(100)
SquadHTS01:AddMissionCapability({AUFTRAG.Type.OPSTRANSPORT}, 90)


-- AIRWING Kutaisi
local WingKutaisi=AIRWING:New("Warehouse Kutaisi", "35th Air Wing (Kutaisi)") --Ops.AirWing#AIRWING

-- Add squadrons to airwing.
WingKutaisi:AddSquadron(SquadFSQ13)
WingKutaisi:AddSquadron(SquadFSQ14)
WingKutaisi:AddSquadron(SquadHTS01)

-- Payload F-16CM for GCICAP, INTERCEPT and CAP missions. 
WingKutaisi:NewPayload("F-16CM Payload AIM-120C*4, AIM-9X*2, FUEL*2, ECM", 2, {AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.CAP}, 80)

-- Payload A-10C for BAI, CAS, CASENHANCED.
WingKutaisi:NewPayload("A-10C Payload AGM-65G,AGM-65K,GBU-10*2,AIM-9*2,TGP,ECM", 2, {AUFTRAG.Type.BAI, AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED}, 80)

-- Payload UH-1H for OPSTRANSPORT.
WingKutaisi:NewPayload("UH-1H Template", 1, {AUFTRAG.Type.OPSTRANSPORT}, 80)


---
-- CHIEF OF STAFF
---

-- Zone defining the border of the blue territory.
local ZoneBlueBorder=ZONE:New("Blue Border"):DrawZone()

-- Blue agents.
local Agents=SET_GROUP:New():FilterPrefixes("US EWR"):FilterPrefixes("US Reaper"):FilterOnce()

-- Define CHIEF.  
local Chief=CHIEF:New(coalition.side.BLUE, Agents)

-- Add border zone.
Chief:AddBorderZone(ZoneBlueBorder)

-- Enable tactical overview.
Chief:SetTacticalOverviewOn()

-- Add legions(s) [airwings, brigades, flotillas] to the chief.
Chief:AddBrigade(BrigadeKobuleti)
Chief:AddAirwing(WingKutaisi)

-- Set strategy to DEFENSIVE: Only targets within the border of the chief's territory are attacked.
Chief:SetStrategy(CHIEF.Strategy.DEFENSIVE)
  
-- Start Chief after one second.
Chief:__Start(1)

-- Create a resource list for an empty zone and add an ONGUARD mission for up to three IFVs.
local ResourceListEmpty, ResourceIFV=Chief:CreateResource(AUFTRAG.Type.PATROLZONE,  0, 3, GROUP.Attribute.GROUND_IFV)
local ResourceInfAlpha=Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 3, GROUP.Attribute.GROUND_INFANTRY)
local ResourceInfBravo=Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 3, GROUP.Attribute.GROUND_INFANTRY)

-- Resource Infantry Alpha is transported by up to 3 transport helos.
Chief:AddTransportToResource(ResourceInfAlpha, 1, 3, {GROUP.Attribute.AIR_TRANSPORTHELO})

-- Resource Infantry Bravo is transported by up to 2 APCs.
Chief:AddTransportToResource(ResourceInfBravo, 1, 2, {GROUP.Attribute.GROUND_APC})


-- Add strategic zone.
Chief:AddStrategicZone(OpsZoneKobuletiBridgeAlpha, nil, nil, nil, ResourceListEmpty)


---
-- FSM event functions for strategic ops zones
---

--- Function called each time the chief captures a strategic zone.
function Chief:OnAfterZoneCaptured(From,Event,To,OpsZone)
  local opszone=OpsZone --Ops.OpsZone#OPSZONE

  local text=string.format("Hurray, we captured zone %s!", opszone:GetName())
  env.info(text)
end

--- Function called each time a strategic zone becomes empty.
function Chief:OnAfterZoneEmpty(From, Event, To, OpsZone)
  local opszone=OpsZone --Ops.OpsZone#OPSZONE
  
  local text=string.format("Guys, strategic zone %s is now empty and can be captured easily.", opszone:GetName())
  env.info(text)
end

--- Function called each time a strategic opszone is lost to an enemy.
function Chief:OnAfterZoneLost(From, Event, To, OpsZone)
  local opszone=OpsZone --Ops.OpsZone#OPSZONE
  
  local text=string.format("Damn, we lost strategic zone %s.", opszone:GetName())
  env.info(text)
end

--- Function called each time a strategic opszone is attacked by an enemy.
function Chief:OnAfterZoneAttacked(From, Event, To, OpsZone)
  local opszone=OpsZone --Ops.OpsZone#OPSZONE
  
  local text=string.format("Alert! Strategic zone %s is under attack.", opszone:GetName())
  env.info(text)
end

---
-- Intruders
---

local GroupRed=ARMYGROUP:New("Ru Infanry Alpha"):Activate(5)
