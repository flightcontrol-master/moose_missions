-------------------------------------------------------------------------
-- EasyGCICAP 120 - Carrier demo
-------------------------------------------------------------------------
-- Documentation
-- 
-- EasyGCICAP: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.EasyGCICAP.html
-- 
-------------------------------------------------------------------------
-- Demos the use of EASYGCICAP on a carrier
-------------------------------------------------------------------------
-- Date: Aug 2025
-------------------------------------------------------------------------

-- Get the carrier UNIT object - this is the airbase and a warehouse already, no need to set an extra STATIC object for that!
local Carrier = UNIT:FindByName("Carrier")
-- Define a ZONE relative to the carrier, for defense - ZONE_UNIT moves around with the UNIT
local CarrierZone = ZONE_UNIT:New("Carrier Zone",Carrier,UTILS.NMToMeters(100)) -- Core.Zone#ZONE_UNIT
-- Define a ZONE relative to the carrier, with an offset ahead of heading +5° in 50NM distance as CAP point - ZONE_UNIT moves around with the UNIT
local CarrierCAPZone = ZONE_UNIT:New("Carrier Zone",Carrier,5000,{rho=UTILS.NMToMeters(50),theta=5,relative_to_unit=true}) -- Core.Zone#ZONE_UNIT
-- Draw defense zone
CarrierZone:DrawZone(-1,{0,0,1},1,{0,0,1},.15,1,true)
-- Set up EASYGCICAP on a carrier
local CarrierCAP = EASYGCICAP:New("Carrier Ops","Carrier","blue","Blue CVN")
CarrierCAP:AddSquadron("Tomcat","31st Fighter Wing","Carrier",20)
CarrierCAP:SetDefaultCAPAlt(25000)
CarrierCAP:SetDefaultCAPDirection(Carrier:GetHeading())
CarrierCAP:SetDefaultCAPSpeed(350)
CarrierCAP:SetDefaultTakeOffType("hot")
CarrierCAP:AddPatrolPointCAP("Carrier",CarrierCAPZone,25000,350,Carrier:GetHeading(),50) -- The CAP zone is our "moving" zone, the anchor point is updated for every new CAP mission
CarrierCAP:SetDefaultDespawnAfterLanding()
CarrierCAP:AddAcceptZone(CarrierZone)
CarrierCAP:ShowPatrolPointMarkers(true)
MESSAGE:New("EASYGCICAP Carrier Started!",15):ToAll()

-- Redraw function - shows the zone is moving with the carrier
function UpdateZoneDrawings(CarrierZone,DrawID,CarrierCAPCoord)
  CarrierZone:UndrawZone()
  CarrierZone:DrawZone(-1,{0,0,1},1,{0,0,1},.15,1,true)
end
-- Redraw every one minute
local ReDrawTimer  = TIMER:New(UpdateZoneDrawings,CarrierZone):Start(60,60)
