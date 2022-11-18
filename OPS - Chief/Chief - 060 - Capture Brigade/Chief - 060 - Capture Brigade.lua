---
-- CHIEF: Capture Brigade
-- 
-- The blue chief tries to capture a red brigade output near Kobuleti.
-- 
-- When the brigade is captured by blue, the red chief will try to
-- re-capture it.
-- 
-- When the brigade is re-captured by red, the blue chief will try to
-- re-re-capture it.
-- 
-- When the brigade is re-re-captured by blue, the red chief wil try to
-- re-re-re-capture it.
-- 
-- When the, ... (you know the drill)
---

---
-- BLUE Coaliton
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
-- BLUE CHIEF OF STAFF
---

-- Zone defining the border of the blue territory.
local ZoneBlueBorder=ZONE:New("Blue Border"):DrawZone()

-- Blue agents.
local Agents=SET_GROUP:New():FilterPrefixes("US EWR"):FilterPrefixes("US Reaper"):FilterOnce()

-- Define CHIEF.  
local ChiefBlue=CHIEF:New(coalition.side.BLUE, Agents)

-- Add border zone.
ChiefBlue:AddBorderZone(ZoneBlueBorder)

-- Enable tactical overview.
ChiefBlue:SetTacticalOverviewOn()

-- Add legions(s) [airwings, brigades, flotillas] to the chief.
ChiefBlue:AddBrigade(BrigadeKobuleti)

-- Set strategy to DEFENSIVE: Only targets within the border of the chief's territory are attacked.
ChiefBlue:SetStrategy(CHIEF.Strategy.DEFENSIVE)
  
-- Start Chief after one second.
ChiefBlue:__Start(1)


---
-- RED Coaliton
---

-- Platoon of Transportpanzer Fuchs APCs capable of transport and patrol missions.
local PlatoonBTR82=PLATOON:New("IFV BTR-82A Template", 1, "Platoon IFV BTR-82A Alpha")
PlatoonBTR82:AddMissionCapability({AUFTRAG.Type.PATROLZONE}, 70)

-- Platoon of Transportpanzer Fuchs APCs capable of transport and patrol missions.
local PlatoonBTR80=PLATOON:New("APC BTR-80 Template", 1, "Platoon APC BTR-80 Alpha")
PlatoonBTR80:AddMissionCapability({AUFTRAG.Type.OPSTRANSPORT, AUFTRAG.Type.PATROLZONE}, 70)

-- Brigade Kobuleti Outpost Alpha
local BrigadeOutpostAlpha=BRIGADE:New("Outpost Kobuleti Alpha", "Outpost Kobuleti Alpha") --Ops.Brigade#BRIGADE

-- Add platoon.
BrigadeOutpostAlpha:AddPlatoon(PlatoonBTR82)

-- Brigade Kobuleti Outpost Alpha
local BrigadeOutpostBravo=BRIGADE:New("Outpost Kobuleti Bravo", "Outpost Kobuleti Bravo") --Ops.Brigade#BRIGADE

-- Add platoon.
BrigadeOutpostBravo:AddPlatoon(PlatoonBTR80)

---
-- RED CHIEF OF STAFF
---

-- Define CHIEF.  
local ChiefRed=CHIEF:New(coalition.side.RED)

-- Tacview.
ChiefRed:SetTacticalOverviewOn()

-- Add brigades.
ChiefRed:AddBrigade(BrigadeOutpostAlpha)
ChiefRed:AddBrigade(BrigadeOutpostBravo)

ChiefRed:__Start(1)

---
-- FSM Events
---

--- Function called when RED chief loses one of his legions.
function ChiefRed:OnAfterLegionLost(From, Event, To, Legion, Coalition, Country)
  local legion=Legion --Ops.Legion#LEGION
  
  local text=string.format("RED CHIEF: Our legion %s was captured by the %s coalition (country id=%d)", legion:GetName(), UTILS.GetCoalitionName(Coalition), Country)
  MESSAGE:New(text, 120):ToAll()
  env.info(text)
  
  -- Add a mission to recapture the brigade.
  local mission=AUFTRAG:NewPATROLZONE(BrigadeOutpostAlpha:GetWarehouseZone())
  mission:AddConditionSuccess(function() return BrigadeOutpostAlpha:GetCoalition()==coalition.side.RED end)
  ChiefRed:AddMission(mission)
  
end

--- Function called when BLUE chief loses one of his legions.
function ChiefBlue:OnAfterLegionLost(From, Event, To, Legion, Coalition, Country)
  local legion=Legion --Ops.Legion#LEGION
  
  local text=string.format("BLUE CHIEF: Our legion %s was captured by the %s coalition (country id=%d)", legion:GetName(), UTILS.GetCoalitionName(Coalition), Country)
  MESSAGE:New(text, 120):ToAll()
  env.info(text)
  
  -- Add a mission to recapture the brigade.
  local mission=AUFTRAG:NewPATROLZONE(BrigadeOutpostAlpha:GetWarehouseZone())
  mission:AddConditionSuccess(function() return BrigadeOutpostAlpha:GetCoalition()==coalition.side.BLUE end)
  ChiefBlue:AddMission(mission)
  
end


--- Function called when the Brigade was captured by a another Coaltion/Country.
function BrigadeOutpostAlpha:OnAfterCaptured(From, Event, To, Coalition, Country)

  local text=string.format("BRIGADE Outpost Alpha: We were captured by the %d coalition (country id=%d)", Coalition, Country)
  MESSAGE:New(text, 120):ToAll()
  env.info(text)
  
  -- Add brigade to the chief who captured it.
  if Coalition==coalition.side.BLUE then
    ChiefBlue:AddBrigade(BrigadeOutpostAlpha)
  elseif Coalition==coalition.side.RED then
    -- Add brigade to red chief.
    ChiefRed:AddBrigade(BrigadeOutpostAlpha)
  end

end


-- Blue chief sends troops to capture a red brigade. Success if coalition of brigade is blue.
local missionCapture=AUFTRAG:NewPATROLZONE(BrigadeOutpostAlpha:GetWarehouseZone())
missionCapture:AddConditionSuccess(function() return BrigadeOutpostAlpha:GetCoalition()==coalition.side.BLUE end)
ChiefBlue:AddMission(missionCapture)
