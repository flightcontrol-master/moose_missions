---
-- CHIEF: Capture Zone Basic
-- 
-- The blue chief controls brigades located at Kobuleti.
-- 
-- The brigade consists of four platoons:
-- * Infantry for ground attack and on guard missions
-- * APCs of type Fuchs for troop transport missions
-- * IFVs of type Marder for ground attack and transport missions
-- * MBTs of type Leo 2 for ground attack and on guard missions
--
-- We received intel that enemy forces are approaching from the South
-- who want to capture and possibly destroy the strategically important bridge.
-- 
-- We define a zone South of the bridge as strategic zone. As the zone is currently
-- empty the chief will send ground troops to effectively capture it.
-- 
-- Note that the default resources employed in case the zone is empty are:
-- * One Tank group for an ONGUARD mission
-- * Up to three Infantry groups for an ONGUARD mission
-- The infantry is transported by one APC or helicopter if available.
-- 
-- There will be other demo missions that show you how to customize the resources
-- employed in the two cases that a zone is occupied by the enemy and when its empty.  
---


---
-- OPSZONE
-- Define opszone(s) that will become the strategic zones that the chief will capture.
-- The chief will start the zones when they are added.
---

local OpsZoneKobuletiBridgeAlpha=OPSZONE:New("Kobuleti Bridge Alpha") --Ops.OpsZone#OPSZONE

---
-- BRIGADE
---

-- Platoon infantry (five 7 groups of 5 soldiers each).
local Platoon1=PLATOON:New("Infantry M4 Template", 7, "Platoon Infantry M4 Alpha")
Platoon1:SetGrouping(5)
Platoon1:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK, AUFTRAG.Type.ONGUARD}, 70)

-- Platoon of Transportpanzer Fuchs APCs capable of transport missions.
local Platoon2=PLATOON:New("TPz Fuchs Template", 3, "Platoon APC Fuchs Alpha")
Platoon2:AddMissionCapability({AUFTRAG.Type.OPSTRANSPORT}, 90)

-- Platoon of Transportpanzer Fuchs APCs capable of transport missions.
local Platoon3=PLATOON:New("IFV Marder Template", 3, "Platoon IFV Marder Alpha")
Platoon3:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK, AUFTRAG.Type.ONGUARD}, 80)

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

-- Add brigade(s) to the chief.
Chief:AddBrigade(BrigadeKobuleti)

-- Set strategy to DEFENSIVE: Only targets within the border of the chief's territory are attacked.
Chief:SetStrategy(CHIEF.Strategy.DEFENSIVE)
  
-- Start Chief after one second.
Chief:__Start(1)

-- Add strategic zone.
Chief:AddStrategicZone(OpsZoneKobuletiBridgeAlpha)


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
