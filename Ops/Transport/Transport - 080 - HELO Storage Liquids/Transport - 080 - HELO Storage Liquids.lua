---
-- STORAGE: Helo transport liquids
-- 
-- The airbase at Batumi ran out of fuel.
-- 
-- A Chinook from FARP Berlin is ordered to transport 2 tons jet fuel
-- and 2 tons gasoline from Berlin to Batumi.
-- 
-- The helo can load 3751 kg of cargo in total. 
-- So it has to go two times to deliver all liquids.
---

-- Get FARP airbase.
local berlinFARP=AIRBASE:FindByName("FARP Berlin")

-- Get the warehouse storage of FARP Berlin
local berlinStorage=berlinFARP:GetStorage()

-- Get airbase of Batumi.
local batumiAirbase=AIRBASE:FindByName("Batumi")

-- Get the warehouse storage of Batumi airbase.
local batumiStorage=batumiAirbase:GetStorage()

-- Pickup and deploy base. NOTE that we use ZONE_AIRBASE here, so the helo lands at the airbase.
local zonePickup=ZONE_AIRBASE:New("FARP Berlin", 2000)
local zoneDeploy=ZONE_AIRBASE:New(AIRBASE.Caucasus.Batumi, 2000)


-- Create a transport from pickup at Berlin to Batumi. The first parameter has to be nil, as this applies only to troop tansports.
local transport=OPSTRANSPORT:New(nil, zonePickup, zoneDeploy)

-- Define the cargo transport from Berlin to Batumi. We need to pass the STORAGE from which the cargo is taken and the STORAGE to which it should be delivered. 
-- Add storage amount to deliver from Berlin to Batumi. We want 2000 kg of jet fuel and 2000 kg Diesel.
transport:AddCargoStorage(berlinStorage, batumiStorage, STORAGE.Liquid.JETFUEL, 2000)
transport:AddCargoStorage(berlinStorage, batumiStorage, STORAGE.Liquid.GASOLINE, 2000)

-- Create armygroup object.
local helo=FLIGHTGROUP:New("CH-47D Alpha")

-- Assign transport to truck.  
helo:AddOpsTransport(transport)


--- Function to report the current amount of fuel at Berlin and Batumi
local function reportStorage()
  local text=string.format("Current storage amount:\n")
  local text=string.format("Berlin has %d kg of jet fuel and %d kg of gasoline\n", berlinStorage:GetAmount(STORAGE.Liquid.JETFUEL), berlinStorage:GetAmount(STORAGE.Liquid.GASOLINE))
  text=text..string.format("Batumi has %d kg of jet fuel and %d kg of gasoline",   batumiStorage:GetAmount(STORAGE.Liquid.JETFUEL), batumiStorage:GetAmount(STORAGE.Liquid.GASOLINE))
  MESSAGE:New(text, 300):ToAll():ToLog()
end

-- Report initial storage.
reportStorage()

--- Function called after truck has loaded a batch of cargo.
function helo:OnAfterLoadingDone(From, Event, To)
  -- Report storage after truck has loaded all its current cargo.
  reportStorage()
end

--- Function called after truck has unloaded a batch of cargo.
function helo:OnAfterUnloadingDone(From,Event,To)
  -- Report storage after truck has delivered all its current cargo.
  reportStorage()
end

--- Function called when transport was delivered or everyone (remaining) is dead.
function transport:OnAfterDelivered(From, Event, To)

  -- Report that everything was delivered
  local text=string.format("Transport UID=%d was delivered. Ncargo=%d Ndelivered=%d", transport:GetUID(), transport:GetNcargoTotal(), transport:GetNcargoDelivered())
  MESSAGE:New(text, 300):ToAll():ToLog()
  
  -- Report storage after everything was delivered.
  reportStorage()
end