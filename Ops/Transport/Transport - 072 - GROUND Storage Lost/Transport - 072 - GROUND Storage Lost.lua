---
-- STORAGE: Cargo Lost
-- 
-- The airbase at Batumi ran out of Diesel.
-- 
-- Two groups of trucks are ordered to transport 6 tons Diesel from nearby FRAP Berlin to Batumi.
-- Truck group Alpha consists of one truck while group Bravo consists of two trucks.
-- 
-- Each truck can load ~1140 kg of cargo at once.
--
-- After truck Alpha has loaded its fuel, it comes to an explosion. The loaded cargo is lost
-- and only group Bravo can deliver the fuel.
-- 
-- The amount of Diesel taken from Berlin will be 6 tons but Batumi will only receive 4860 kg beacuse 1140 kg are lost.
---

-- Get FARP airbase.
local berlinFARP=AIRBASE:FindByName("FARP Berlin")

-- Get the warehouse storage of FARP Berlin
local berlinStorage=berlinFARP:GetStorage()

-- Pickup zone near FARP Berlin.
local zonePickup=ZONE:FindByName("Storage Berlin"):DrawZone()


-- Get airbase of Batumi.
local batumiAirbase=AIRBASE:FindByName("Batumi")

-- Get the warehouse storage of Batumi airbase.
local batumiStorage=batumiAirbase:GetStorage()

-- Deploy zone at Batumi.
local zoneDeploy=ZONE:FindByName("Storage Batumi"):DrawZone()


-- Create a transport from pickup at Berlin to Batumi. The first parameter has to be nil, as this applies only to troop tansports.
local transport=OPSTRANSPORT:New(nil, zonePickup, zoneDeploy)

-- Add storage amount to deliver from Berlin to Batumi.
transport:AddCargoStorage(berlinStorage, batumiStorage, STORAGE.Liquid.DIESEL, 6000)

-- Create armygroup object.
local truckAlpha=ARMYGROUP:New("Truck M939 Alpha")

-- Create armygroup object.
local truckBravo=ARMYGROUP:New("Truck M939 Bravo")

-- Assign transport to truck groups.  
truckAlpha:AddOpsTransport(transport)
truckBravo:AddOpsTransport(transport)



--- Function to report the current amount of fuel at Berlin and Batumi
local function reportStorage()
  local text=string.format("Current storage amount:\n")
  local text=string.format("Berlin has %d kg Diesel\n", berlinStorage:GetAmount(STORAGE.Liquid.DIESEL))
  text=text..string.format("Batumi has %d kg Diesel",   batumiStorage:GetAmount(STORAGE.Liquid.DIESEL))
  MESSAGE:New(text, 300):ToAll():ToLog()
end

-- Report initial storage.
reportStorage()

--- Function called after truck has loaded a batch of cargo.
function truckAlpha:OnAfterLoadingDone(From, Event, To)
  reportStorage()
  truckAlpha:SelfDestruction(3*60, 50)
end

--- Function called after truck has unloaded a batch of cargo.
function truckAlpha:OnAfterUnloadingDone(From, Event, To)
  reportStorage()
end

--- Function called after truck has loaded a batch of cargo.
function truckBravo:OnAfterLoadingDone(From, Event, To)
  reportStorage()
end

--- Function called after truck has unloaded a batch of cargo.
function truckBravo:OnAfterUnloadingDone(From, Event, To)
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