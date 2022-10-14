---
-- CHIEF: A2A Intercept Response
-- 
-- The blue chief controls one airwing located at Kutaisi. 
-- 
-- The airwing has two squadrons
-- * F-16CMs for INTERCEPT missions
-- * A-10C for BAI and CAS missions
-- 
-- The airwing has a limited number of payloads for A2A and A2G missions.
-- 
-- Intel is provided from and AN/FPS 117 early warning radar and a Reaper drone.
-- 
-- The strategy of the chief is DEFENSIVE, i.e. he will only engage detected enemies
-- that are within his own territory.
-- 
-- The Reaper will 
---

--- F-16 Fighter Squadron.
local SquadFSQ13=SQUADRON:New("F-16CM Template", 5, "13th Fighter Squadron") --Ops.Squadron#SQUADRON
SquadFSQ13:SetGrouping(1) -- One aircraft per group.
SquadFSQ13:SetModex(130)  -- Tail number of the sqaud start with 130, 131,...
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 90) -- Squad can do intercept missions.
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.ALERT5})        -- Squad can be spawned at the airfield in uncontrolled state.
SquadFSQ13:SetMissionRange(200) -- Squad will be considered for targets within 200 NM of its airwing location.

--- A-10C Fighter Squadron.
local SquadFSQ14=SQUADRON:New("A-10C Template", 5, "14th Fighter Squadron") --Ops.Squadron#SQUADRON
SquadFSQ14:SetGrouping(1) -- One aircraft per group.
SquadFSQ14:SetModex(140)  -- Tail number of the sqaud start with 140, 141,...
SquadFSQ14:AddMissionCapability({AUFTRAG.Type.BAI, AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED}, 90) -- Squad can do BAI and CAS missions
SquadFSQ14:AddMissionCapability({AUFTRAG.Type.ALERT5})        -- Squad can be spawned at the airfield in uncontrolled state.
SquadFSQ14:SetMissionRange(200) -- Squad will be considered for targets within 200 NM of its airwing location.


--- AIRWING Kutaisi
local WingFW35=AIRWING:New("Warehouse Kutaisi", "35th Air Wing (Kutaisi)") --Ops.AirWing#AIRWING

-- Add squadrons to airwing.
WingFW35:AddSquadron(SquadFSQ13)
WingFW35:AddSquadron(SquadFSQ14)

-- Payload F-16CM for GCICAP, INTERCEPT and CAP missions. 
WingFW35:NewPayload("F-16CM Payload AIM-120C*4, AIM-9X*2, FUEL*2, ECM", 2, {AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.CAP}, 80)

-- Payload A-10C for BAI, CAS, CASENHANCED.
WingFW35:NewPayload("A-10C Payload AGM-65G,AGM-65K,GBU-10*2,AIM-9*2,TGP,ECM", 2, {AUFTRAG.Type.BAI, AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED}, 80)


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

-- Add airwing(s) to the chief.
Chief:AddAirwing(WingFW35)

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

    