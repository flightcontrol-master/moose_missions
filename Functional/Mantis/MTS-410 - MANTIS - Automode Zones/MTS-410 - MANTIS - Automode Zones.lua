-------------------------------------------------------------------------
-- MTS-410 - MANTIS - Automode and Zones
-------------------------------------------------------------------------
-- Documentation
-- 
-- MANTIS: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Mantis.html
-- 
-------------------------------------------------------------------------
-- Observe a set of SAM sites being attacked by F16 SEAD. Red SAMs will
-- go active once the F16s have passed the red border and the DMZ.
-- The SAM network and the SHORAD are managed by MANTIS. 
-------------------------------------------------------------------------
-- Date: 13 Nov 2021

-- Borders
local blueborder = ZONE_POLYGON:New("BlueBorder",GROUP:FindByName("Blue Border"))
local redborder = ZONE_POLYGON:New("RedBorder",GROUP:FindByName("Red Border"))
local dmz = ZONE:New("DMZ")

-- MANTIS
local RedMantis = MANTIS:New("RedMantis","Red SAM","Red EWR",nil,"red",nil,nil,true)
RedMantis:SetDetectInterval(30)
RedMantis:AddZones({redborder},{blueborder,dmz}) --accept and reject zones
RedMantis:SetSAMRange(90)
RedMantis.verbose = false
RedMantis:Debug(false)
RedMantis:__Start(5)

function RedMantis:OnAfterSeadSuppressionPlanned(From, Event, To, Group, Name, SuppressionStartTime, SuppressionEndTime)
MESSAGE:New("SAM Suppression planned! "..Name.. " is planning to shut down.",10):ToAll()
env.info("SAM Suppression planned! "..Name.. " is planning to shut down.")
end

function RedMantis:OnAfterSeadSuppressionStart(From, Event, To, Group, Name)
MESSAGE:New("SAM Suppressed! "..Name.. " is suppressed.",10):ToAll()
env.info("SAM Suppressed! "..Name.. "is suppressed!" )
end

function RedMantis:OnAfterRedState(From,Event,To,Group)
  local Name = Group:GetName()
  MESSAGE:New("SAM "..Name.. " switched to RED",10):ToAll()
  env.info("SAM "..Name.. " switched to RED" )
end

function RedMantis:OnAfterGreenState(From,Event,To,Group)
  local Name = Group:GetName()
  MESSAGE:New("SAM "..Name.. " switched to GREEN",10):ToAll()
  env.info("SAM "..Name.. " switched to GREEN" )
end

function RedMantis:OnAfterShoradActivated(From,Event,To,Name,Radius,Ontime)
  MESSAGE:New("SHORAD for "..Name.. " going online!",10):ToAll()
  env.info("SHORAD for "..Name.. " going online!" )
end

-- get some blue attackers
function GetBlueSEAD()
  local BlueCAS = SPAWN:New("F16 Flight")
    :InitCleanUp(30)
    :InitLimit(3,0)
    :InitDelayOff()
    :SpawnScheduled(30,0.5)
end

local bluetimer = TIMER:New(GetBlueSEAD)
bluetimer:Start(20)