---
-- CHIEF: A2A Intercept Response
-- 
-- The blue chief controls one airwing located at Kutaisi. 
-- 
-- The airwing has one squadron of 5 F-16CMs.
-- The squadron is capable of INTERCEPT missions only.
-- The airwing has a limited number of payloads for intercept missions.
-- 
-- Intel is provided from one AN/FPS 117 early warning radar.
-- 
-- The strategy of the chief is DEFENSIVE, i.e. he will only engage detected enemies
-- that are within his own territory.
-- 
-- A red intruder Tu-142 is crossing the border into blue territory.
-- 
-- Up to this point, this demo is idential to the "Chief - 010- A2A Dispatcher Basic" demo.
-- However, here we customize the response to send up to four F-16 groups for the intercept
-- as the threat level of the Tu-142 is 6 (see line Chief:SetResponseOnTarget).
-- Only two will actually go on the mission, as the airwing has only that many payloads available.
---

--- F-16 Fighter Squadron.
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

-- Blue agents.
local Agents=SET_GROUP:New():FilterPrefixes("US EWR"):FilterOnce()

-- Define CHIEF.  
local Chief=CHIEF:New(coalition.side.BLUE, Agents)

-- Add border zone.
Chief:AddBorderZone(ZoneBlueBorder)

-- Enable tactical overview.
Chief:SetTacticalOverviewOn()

-- Launch at least one but at most four asset groups for INTERCEPT missions if the threat level of the target is great or equal to six.
Chief:SetResponseOnTarget(1, 4, 6, nil, AUFTRAG.Type.INTERCEPT)

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

    