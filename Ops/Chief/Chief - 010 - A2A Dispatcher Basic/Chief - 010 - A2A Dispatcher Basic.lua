---
-- CHIEF: A2A Dispatcher Basic
-- 
-- A blue chief controls one airwing located at Kutaisi. 
-- 
-- The airwing has one squadron of 5 F-16CMs.
-- The squadron is capable of INTERCEPT missions only.
-- The airwing has a limited number of payloads for intercept missions.
-- 
-- Intel is provided from one AN/FPS 117 early warning radar (EWR).
-- 
-- The strategy of the chief is DEFENSIVE, i.e. he will only engage detected enemies
-- that are within his own territory.
-- 
-- A red intruder Tu-142 is crossing the border into blue territory.
-- 
-- The chief will react and launch a flight of one F-16 on an INTERCEPT mission.
---

--- F-16 Fighter Squadron consiting of 5 single ship asset groups.
local SquadFSQ13=SQUADRON:New("F-16CM Template", 5, "13th Fighter Squadron") --Ops.Squadron#SQUADRON
SquadFSQ13:SetGrouping(1) -- One aircraft per group.
SquadFSQ13:SetModex(130)  -- Tail number of the sqaud start with 130, 131,...
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.INTERCEPT}, 90) -- Squad can do intercept missions.
SquadFSQ13:AddMissionCapability({AUFTRAG.Type.ALERT5})        -- Squad can be spawned at the airfield in uncontrolled state.
SquadFSQ13:SetMissionRange(200) -- Squad will be considered for targets within 200 NM of its airwing location.


--- AIRWING Kutaisi
local WingFW35=AIRWING:New("Warehouse Kutaisi", "35th Air Wing (Kutaisi)") --Ops.AirWing#AIRWING

-- Add squadrons to airwing.
WingFW35:AddSquadron(SquadFSQ13)

-- Payload: This payload is used for GCICAP, INTERCEPT and CAP missions. 
--          Only two are available ==> Only two missions can be started simultaniously.
--          Payloads are returned when the assets returns to the airwing.
WingFW35:NewPayload("F-16CM Payload AIM-120C*4, AIM-9X*2, FUEL*2, ECM", 2, {AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.CAP}, 80)

---
-- CHIEF OF STAFF
---

-- Zone defining the border of the blue territory.
local ZoneBlueBorder=ZONE:New("Blue Border"):DrawZone()

-- Blue agents. We include all groups contain the string "US EWR".
local Agents=SET_GROUP:New():FilterPrefixes("US EWR"):FilterOnce()

-- Define blue CHIEF.  
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

--- Function called each time the Chief sends an asset group on a mission.
function Chief:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
  local opsgroup=OpsGroup --Ops.OpsGroup#OPSGROUP
  local mission=Mission   --Ops.Auftrag#AUFTRAG
  
  -- Info message to log file which group is launched on which mission.
  local text=string.format("Group %s is on mission %s [%s]", opsgroup:GetName(), mission:GetName(), mission:GetType())
  env.info(text)
  
end

    