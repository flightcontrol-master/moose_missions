---
-- CHIEF: G2G Dispatcher Basic
-- 
-- The blue chief controls one brigade located at Kobuleti.
-- 
-- The brigade consists of a single platoon only, which has Leopard 2 tanks as 
-- assets and is capable of ground attack missions.
--   
-- A Reaper drone will detect targets near Kobuleti.
-- 
-- The chief will send a Leo to destroy the targets, because they are in his own
-- territory (current stragety DEFENSIVE).
-- 
-- NOTE that the preferred automatic response would be an air-to-ground missions (BAI).
-- But as no air assets available the G2G option is chosen.  
---

---
-- BRIGADE
---

-- Platoon of Leopard 2 tanks capable of GROUNDATTACK missions.
local Platoon1=PLATOON:New("MBT Leopard-2A6M Template", 5, "Platoon Leopard Alpha")
Platoon1:AddMissionCapability({AUFTRAG.Type.GROUNDATTACK}, 90)

-- Brigade at Kobuleti
local BrigadeKobuleti=BRIGADE:New("Warehouse Kobuleti", "Brigade Kobuleti") --Ops.Brigade#BRIGADE

-- Add platoon(s) to brigade.
BrigadeKobuleti:AddPlatoon(Platoon1)


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


--- Function called each time Chief Agents detect a new contact.
function Chief:OnAfterNewContact(From, Event, To, Contact)

  -- Gather info of contact.
  local ContactName=Chief:GetContactName(Contact)
  local ContactType=Chief:GetContactTypeName(Contact)
  local ContactThreat=Chief:GetContactThreatlevel(Contact)
  
  -- Text message.
  local text=string.format("Detected NEW contact: Name=%s, Type=%s, Threat Level=%d", ContactName, ContactType, ContactThreat)
  
  -- Show message in log file.
  env.info(text)
  
end

    