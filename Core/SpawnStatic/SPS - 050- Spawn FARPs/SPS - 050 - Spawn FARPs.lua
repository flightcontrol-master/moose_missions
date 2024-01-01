---
-- FARPS
-- This demo shows how to dynamically spawn FARPs into a mission.
-- 
-- We spawn two FARPS in a zone near Batumi.
-- The first FARP is names "FARP Berlin" and the second "FARP London".
-- We put coloured smoke on the spawned objects to mark them.
-- 
-- The data is taken from "template" FARPS. Note that if the same
-- name as the template is used, the original object is despawned
-- automatically when the new object is spawned.
-- 
-- As FARPS in DCS are strange creatures, which are hybrids of groups
-- and statics, the function :InitFARP is necessary.
---

-- Zone near Batumi on land.
local ZoneSpawn=ZONE:FindByName("Spawn Land")


-- Create a SPAWNSTATIC object from a template static FARP object.
local SpawnStaticFarp=SPAWNSTATIC:NewFromStatic("Static FARP Template-1", country.id.GERMANY)


-- Spawning FARPS is special in DCS. Therefore, we need to specify that this is a FARP. We also set the callsign and the frequency.
SpawnStaticFarp:InitFARP(CALLSIGN.FARP.Berlin, 130.000, 0)

-- Spawn FARP with heading 90°. It's name will be "Farp Berlin".
local FarpBerlin=SpawnStaticFarp:SpawnFromZone(ZoneSpawn, 90, "FARP Berlin")

-- Smoke static green.
FarpBerlin:GetCoordinate():SmokeGreen()


-- The second FAPR gets callsign London and used radio frequency 131 MHz.
SpawnStaticFarp:InitFARP(CALLSIGN.FARP.London, 131.000, 0)

-- We set the country to UK.
SpawnStaticFarp:InitCountry(country.id.UK)

-- Spawn the FARP at a random location inside the zone.
local FarpLondon=SpawnStaticFarp:SpawnFromCoordinate(ZoneSpawn:GetRandomCoordinate(), nil, "Farp London")

-- Put red smoke at FARP London.
FarpLondon:GetCoordinate():SmokeRed()


-- Function to check if the STATIC/AIRBASE objects can be found.
local function check()

  -- Try to find static.
  local StaticBerlin=STATIC:FindByName("FARP Berlin")
  
  -- Launch red flare.
  StaticBerlin:GetCoordinate():FlareRed()
  
  -- Get the airbase object.
  local AirbaseBerlin=AIRBASE:FindByName("FARP Berlin")
  AirbaseBerlin:MarkParkingSpots()

end
TIMER:New(check):Start(1)