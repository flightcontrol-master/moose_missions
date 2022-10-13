-------------------------------------------------------------------------
-- Chief / Airwing / Squadron Demo by Taco
-------------------------------------------------------------------------
-- (Anything this color blue or green are just my notes to you, doesn't 
-- get read as code, so it's a lot less code than it appears)
-------------------------------------------------------------------------
-- Goal: Semi-Autonomous Red Chief, with assets at his disposal to defend
--       a pre-defined zone. 
-------------------------------------------------------------------------
-- Proceduce:
--  1. Define necessary zones.
--  2. Configure CHIEF
--  3. Set up an AIRWING
--  4. Set up basic GCI CAP
--  5. (Optional) Put units on Alert 5.
-------------------------------------------------------------------------

--Debug Settings
local RedDebug = true  --change to false to get rid of text pop ups and many of the log messages.  Switch to false before live mission night.

--- +-----------------------------+
--- |     1. DEFINE ZONES         |
--- +-----------------------------+

--BORDERS
local BlueBorderZones = ZONE_POLYGON:New("Blue Border", GROUP:FindByName("BlueBorder"))  -- There needs to be a late-activated unit in-game with the GROUP name "Blueborder".  
local RedBorderZones  = ZONE_POLYGON:New("Red Border", GROUP:FindByName("RedBorder"))    -- Same for RedBorder, these define the Blue and Red Borders for Chief (and other things later on we can add to this)

-- CAP zone where red flights will patrol.
local CAPZone1= ZONE:New("CAPZone1")                                                    --Must be a Zone set in Mission Editor named "CAPZone1", case-sensitive
   
--- +-----------------------------+
--- |     2. CONFIGURE RED CHIEF  |
--- +-----------------------------+

--All red units are put into a 'set' which provide intel to the RedChief (radars, planes, anything that can see...radars being the most helpful)
local RedIntelProviders = SET_GROUP:New():FilterCoalitions("red"):FilterStart()  --#SET_GROUP
  
--We create an instance of CHIEF, we'll call it RedChief.  A Chief autnomously creates missions (auftrags, since it was written by a German guy) based on targets and zones.    
local RedChief = CHIEF:New(coalition.side.RED, RedIntelProviders, "Red Chief")              --Ops.Chief#CHIEF

-- Debug options.
if RedDebug then  -- if the variable RedDebug is 'true' we show these settings on-screen and in the log. 
  RedChief:SetVerbosity(3) -- More output to the DCS log file.
  RedChief:SetClusterAnalysis(true, true, true) -- Enable Intel clusters and markers (this is hard on the server, so important to have off when running for real, but helps you see what Chief sees). Need to choose a Red slot or Observer to see it.
  RedChief:SetTacticalOverviewOn() -- Helpful overview showing what Auftrags and running and what supplies Chief has at his disposal. Need to choose a Red slot or Observer to see it.
end
  
-- Add border zone.
RedChief:AddBorderZone(RedBorderZones)          -- We tell RedChief these are his borders  [NOTE: IF YOU ARE USING A SET, USE SETBORDERZONES, IF USING A POLYGON USE AddBorderZone]

-- Set strategy.
RedChief:SetStrategy(CHIEF.Strategy.DEFENSIVE)  -- We set a Strategy, Defensive means RedChief will protect his own borders, but not engage anything outside of them.

-- Limit number of missions.
RedChief:SetLimitMission(2, AUFTRAG.Type.INTERCEPT)  -- If you want, we can limit how many Intercepts Chief tasks at once, to prevent us from getting overwhelmed.

--- +-----------------------------+
--- |    3. SET UP AN AIRWING     |
--- +-----------------------------+

-- An AIRWING is a digital warehouse, located within a unit or static placed in the Mission Editor (ME)
local AkrotiriAirwing = AIRWING:New("Akrotiri Airwing", "Akrotiri Airwing")  

-- Let's give the Airwing a SQUADRON of 4 assets of Mig29s so it can do stuff.  If an asset is a 2-ship, then this is 8 jets.

local Mig29Squadron = SQUADRON:New( "Mig29s" , 4 , "Drax's Dangerous Mig 29s" ) -- There must be a late-activated group in ME with the group name "Mig29s", ideally their Unit Name as well.
Mig29Squadron:SetSkill(AI.Skill.AVERAGE)  -- Don't want to make them too good.
Mig29Squadron:SetTakeoffHot()  -- Spawns with engines running, can also be SetTakeoffCold or SetTakeoffAir. Cold is default behavior.
Mig29Squadron:AddMissionCapability({AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ESCORT, AUFTRAG.Type.ALERT5}, 100)  --Types of missions that this airframe is capable of doing, and a score.

-- Add the SQUADRON's airframe to the AIRWING.
AkrotiriAirwing:AddSquadron(Mig29Squadron)
      
-- An AIRWING needs both airframes and payloads, so next we give the AIRWING an unlimited amount of the payload that's on our late-activated unit.
AkrotiriAirwing:NewPayload("Mig29s", -1, {AUFTRAG.Type.CAP, AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.ESCORT, AUFTRAG.Type.ALERT5 }, 100)  -- Note this uses the UNIT NAME      

-- Finally, we put the AIRWING under RedChief's authority.
RedChief:AddAirwing(AkrotiriAirwing)

--- Function called each time a flight group is send on a mission.
function AkrotiriAirwing:OnAfterFlightOnMission(From, Event, To, Flightgroup, Mission)  --We'll use this to expand functionality later.  Not strictly necessary now, but helpful.
  local flightgroup = Flightgroup -- Ops.FlightGroup#FLIGHTGROUP
  local mission = Mission -- Ops.Auftrag#AUFTRAG
    
  -- Info message.
  local text=string.format("Group %s on mission %s [%s]", flightgroup:GetName(), mission:GetName(), mission:GetType())
  MESSAGE:New(text, 120):ToAll()
  env.info(text)
  
end


--- +-----------------------------+
--- |    4. SET A BASIC CAP TASK  |
--- +-----------------------------+

-- RedChief will keep one group on GCI CAP Orbit at this zone.
-- CAP guys will anchor at the centerpoint of WestCAPZone, at 25,000 Ft, doing 275 KIAS, on 15 mile-long legs due north-south.  When they run low on fuel, Chief will rotate in another group.
RedChief:AddGciCapZone(CAPZone1, 25000, 275, 0, 15)

-- Start chief after 5 seconds. FMS Commands with double underscore "__" cause a delay by the specified number of seconds. 
RedChief:__Start(5)  -- After 5 seconds, start the Chief! 


--- +----------------+
--- |    5. ALERT 5  |
--- +----------------+

--NOTE: We could stop there, but if you want those Mig29s to be visible before they're tasked, here's how you do it.

--Set out 2 Groups of Interceptors.  Note that whatever payload they spawn with, they're stuck with.
local AkrotiriInterceptAlert5=AUFTRAG:NewALERT5(AUFTRAG.Type.INTERCEPT)
AkrotiriInterceptAlert5:SetRequiredAssets(2)

-- Add the mission to the airwing.
-- NOTE: We could also add the mission to the CHIEF. But then we would not know which airwing he choses if he has more than one. Here it does not matter.
AkrotiriAirwing:AddMission(AkrotiriInterceptAlert5)

--Set out 2 Groups of Ground-Controlled CAP fighters.
local AkrotiriGCICAPAlert5s=AUFTRAG:NewALERT5(AUFTRAG.Type.GCICAP)
AkrotiriGCICAPAlert5s:SetRequiredAssets(2)
      
-- Add mission to airwing.
AkrotiriAirwing:AddMission(AkrotiriGCICAPAlert5s)
