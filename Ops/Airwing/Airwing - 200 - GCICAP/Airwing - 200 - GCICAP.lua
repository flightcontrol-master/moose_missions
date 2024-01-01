-------------------------------------------------------------------------
-- Airwing: CAP/GCI Setup
-------------------------------------------------------------------------
-- Documentation
-- 
-- AIRWING: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html
-- 
-------------------------------------------------------------------------
-- Example of a non-CHIEF setup for an AI_A2A-like engagement using CAP
-- and GCI.
-------------------------------------------------------------------------
-- Date: September 2023
-------------------------------------------------------------------------

-- overhead to determine how many aircraft to launch as GCI
local overhead = 0.75
-- range for engage on detected, in NM
local engagerange = 50
-- number of CAP flights per zone
local capgrouping = 2

-- Set up borders
local BlueBorder = ZONE_POLYGON:New( "Blue Border", GROUP:FindByName( "Blue Border" ) )
BlueBorder:DrawZone(-1,{0,0,1},1,FillColor,FillAlpha,1,true)
local BlueNoGoZone = ZONE_POLYGON:New("Red Defense Zone", GROUP:FindByName( "Red Defense Zone" ))
BlueNoGoZone:DrawZone(-1,{1,0,0},1,FillColor,FillAlpha,2,true)
local BlueNoGoZone2 = ZONE_POLYGON:New( "Red Border", GROUP:FindByName( "Red Border" ) )

local BlueNoGoZoneSet = SET_ZONE:New()
BlueNoGoZoneSet:AddZone(BlueNoGoZone2)

local BlueGoZoneSet = SET_ZONE:New()
BlueGoZoneSet:AddZone(BlueBorder)
BlueGoZoneSet:AddZone(BlueNoGoZone)

-- Create first Airwing
local Blue_CAP_Kutaisi = AIRWING:New("Kutaisi","Blue CAP Kutaisi")
Blue_CAP_Kutaisi:SetReportOff()
Blue_CAP_Kutaisi:SetMarker(false)
Blue_CAP_Kutaisi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
Blue_CAP_Kutaisi:SetRespawnAfterDestroyed(900)
Blue_CAP_Kutaisi:SetNumberCAP(capgrouping)
local PatrolCoordinateKutaisi = ZONE:New("Blue Zone 2"):GetCoordinate()
Blue_CAP_Kutaisi:AddPatrolPointCAP(PatrolCoordinateKutaisi,25000,UTILS.KnotsToAltKIAS(300,25000),40,15)
Blue_CAP_Kutaisi:SetTakeoffHot()
Blue_CAP_Kutaisi:Start()

function Blue_CAP_Kutaisi:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
  local flightgroup = Flightgroup -- Ops.FlightGroup#FLIGHTGROUP
  flightgroup:SetDespawnAfterLanding()
  flightgroup:SetDestinationbase(AIRBASE:FindByName(AIRBASE.Caucasus.Kutaisi))
  flightgroup:GetGroup():CommandEPLRS(true,5)
  flightgroup:SetEngageDetectedOn(engagerange,{"Air"},BlueGoZoneSet,BlueNoGoZoneSet)
  flightgroup:GetGroup():OptionROTEvadeFire()
  flightgroup:SetOutOfAAMRTB()
  
  function flightgroup:OnAfterHolding(From,Event,To)
    self:ClearToLand(5)
  end 
  
end

-- Create second Airwing
local Blue_CAP_Sukhumi = AIRWING:New("Sukhumi","Blue CAP Sukhumi")
Blue_CAP_Sukhumi:SetReportOff()
Blue_CAP_Sukhumi:SetMarker(false)
Blue_CAP_Sukhumi:SetAirbase(AIRBASE:FindByName(AIRBASE.Caucasus.Sukhumi))
Blue_CAP_Sukhumi:SetRespawnAfterDestroyed(900)
Blue_CAP_Sukhumi:SetNumberCAP(capgrouping)
local PatrolCoordinateSukhumi = ZONE:New("Blue Zone 1"):GetCoordinate()
Blue_CAP_Sukhumi:AddPatrolPointCAP(PatrolCoordinateSukhumi,25000,UTILS.KnotsToAltKIAS(300,25000),40,15)
Blue_CAP_Sukhumi:SetTakeoffHot()
Blue_CAP_Sukhumi:Start()

function Blue_CAP_Sukhumi:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)
  local flightgroup = Flightgroup -- Ops.FlightGroup#FLIGHTGROUP
  flightgroup:SetDespawnAfterLanding()
  flightgroup:SetDestinationbase(AIRBASE:FindByName(AIRBASE.Caucasus.Sukhumi))
  flightgroup:GetGroup():CommandEPLRS(true,5)
  flightgroup:SetEngageDetectedOn(engagerange,{"Air"},BlueGoZoneSet,BlueNoGoZoneSet)
  flightgroup:GetGroup():OptionROTEvadeFire()
  flightgroup:SetOutOfAAMRTB()
  
  function flightgroup:OnAfterHolding(From,Event,To)
    self:ClearToLand(5)
  end 
  
end

-- Add Squadrons
local Squadron_One = SQUADRON:New("Blue Sq1 M2000c",20,"CAP Kutaisi")
Squadron_One:AddMissionCapability({AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT})
Squadron_One:SetFuelLowRefuel(true)
Squadron_One:SetFuelLowThreshold(0.3)
Squadron_One:SetTurnoverTime(10,20)

local Squadron_Two = SQUADRON:New("Blue Sq2 F15",20,"CAP Sukhumi")
Squadron_Two:AddMissionCapability({AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.GCICAP, AUFTRAG.Type.CAP})
Squadron_Two:SetFuelLowRefuel(true)
Squadron_Two:SetFuelLowThreshold(0.3)
Squadron_Two:SetTurnoverTime(10,20)

Blue_CAP_Kutaisi:AddSquadron(Squadron_One)
Blue_CAP_Kutaisi:NewPayload("Blue Sq1 M2000c",-1,{AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},65)

Blue_CAP_Sukhumi:AddSquadron(Squadron_Two)
Blue_CAP_Sukhumi:NewPayload("Blue Sq2 F15",-1,{AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT},75)

-- Border GCI Detection
local BlueAir_DetectionSetGroup = SET_GROUP:New()
BlueAir_DetectionSetGroup:FilterPrefixes( { "Blue EWR" } )
BlueAir_DetectionSetGroup:FilterOnce()

-- Intel type detection
local BlueIntel = INTEL:New(BlueAir_DetectionSetGroup,"blue","Blue EWR")
BlueIntel:SetClusterAnalysis(true,false,false)
BlueIntel:SetForgetTime(300)
BlueIntel:AddAcceptZone(BlueBorder)
BlueIntel:AddAcceptZone(BlueNoGoZone)
BlueIntel:AddRejectZone(BlueNoGoZone2)
BlueIntel:SetVerbosity(0)
BlueIntel:Start()

-- We'll work with this set on the determination of closest airbase
local BlueCapZoneSet = {
  ["Sukhumi"] = { Blue_CAP_Sukhumi, ZONE:New("Blue Zone 1"), "Sukhumi" },
  ["Kutaisi"] = { Blue_CAP_Kutaisi, ZONE:New("Blue Zone 2"), "Kutaisi" },
}

-- Here, we'll decide if we need to launch an intercepting flight, and from where
function BlueIntel:OnAfterNewCluster(From,Event,To,Cluster)
  -- Aircraft?
  if Cluster.ctype ~= INTEL.Ctype.AIRCRAFT then return end
  -- Threatlevel 0..10
  local contact = self:GetHighestThreatContact(Cluster)
  local name = contact.groupname --#string
  local threat = contact.threatlevel --#number
  local position = self:CalcClusterFuturePosition(Cluster,300)
  -- calculate closest zone
  local bestdistance = 2000*1000 -- 2000km
  local targetairwing = nil -- Ops.AirWing#AIRWING
  local targetawname = "" -- #string
  local clustersize = self:ClusterCountUnits(Cluster) or 1
  local wingsize = math.abs(overhead * (clustersize+1))
  if (not Cluster.mission) and (wingsize > 0) then
   MESSAGE:New(string.format("**** Blue Interceptors need wingsize %d", wingsize),15,"CAPGCI"):ToAll():ToLog()
    for _,_data in pairs (BlueCapZoneSet) do
      local airwing = _data[1] -- Ops.AirWing#AIRWING
      local zone = _data[2] -- Core.Zone#ZONE
      local zonecoord = zone:GetCoordinate()
      local name = _data[3] -- #string
      local distance = position:DistanceFromPointVec2(zonecoord)
      local airframes = airwing:CountAssets(true)
      if distance < bestdistance and airframes >= wingsize then
        bestdistance = distance
        targetairwing = airwing
        targetawname = name
      end
    end
    local text = string.format("Closest Airwing is %s", targetawname)
    local m = MESSAGE:New(text,10,"CAPGCI"):ToAll():ToLog()
    -- Do we have a matching airwing?
    if targetairwing then
      local AssetCount = targetairwing:GetAssetsOnMission({AUFTRAG.Type.INTERCEPT})
      -- Enough airframes on mission already?
      if #AssetCount <= 3 then
        local repeats = math.random(1,2)
        local InterceptAuftrag = AUFTRAG:NewINTERCEPT(contact.group)
          :SetMissionRange(150)
          :SetPriority(1,true,1)
          :SetRequiredAssets(wingsize)
          :SetRepeatOnFailure(repeats)
          :SetMissionSpeed(UTILS.KnotsToAltKIAS(450,25000))
          :SetMissionAltitude(25000)
        targetairwing:AddMission(InterceptAuftrag)
        Cluster.mission = InterceptAuftrag
      end
    else
      MESSAGE:New("**** Not enough airframes available!",15,"CAPGCI"):ToAll():ToLog()
    end
 end
end
