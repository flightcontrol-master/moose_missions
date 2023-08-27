---
-- STORAGE: Liquids 
-- 
-- The airbase at Batumi ran out of fuel.
-- 
-- A truck from the nearby FARP Berlin is ordered to transport
-- 1000 kg jet fuel and 1000 kg diesel to Batumi.
-- 
-- The truck can load ~1140 kg of cargo at once. 
-- So it has to go two times to deliver all liquids.
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

-- Define the cargo transport from Berlin to Batumi. We need to pass the STORAGE from which the cargo is taken and the STORAGE to which it should be delivered. 
--Add storage amount to deliver from Berlin to Batumi. We want 1000 kg of jet fuel and 1000 kg Diesel.
transport:AddCargoStorage(berlinStorage, batumiStorage, STORAGE.Liquid.JETFUEL, 1000)
transport:AddCargoStorage(berlinStorage, batumiStorage, STORAGE.Liquid.DIESEL, 1000)

-- Create armygroup object.
local truck=ARMYGROUP:New("Truck M939 Alpha")

-- Assign transport to truck.  
truck:AddOpsTransport(transport)


--- Function to report the current amount of fuel at Berlin and Batumi
local function reportStorage()
  local text=string.format("Current storage amount:\n")
  local text=string.format("Berlin has %d kg of jet fuel and %d kg of Diesel\n", berlinStorage:GetLiquidAmount(STORAGE.Liquid.JETFUEL), berlinStorage:GetLiquidAmount(STORAGE.Liquid.DIESEL))
  text=text..string.format("Batumi has %d kg of jet fuel and %d kg of Diesel",   batumiStorage:GetLiquidAmount(STORAGE.Liquid.JETFUEL), batumiStorage:GetLiquidAmount(STORAGE.Liquid.DIESEL))
  MESSAGE:New(text, 300):ToAll():ToLog()
end

-- Report initial storage.
reportStorage()

--- Function called after truck has loaded a batch of cargo.
function truck:OnAfterLoadingDone(From, Event, To)
  -- Report storage after truck has loaded all its current cargo.
  reportStorage()
end

--- Function called after truck has unloaded a batch of cargo.
function truck:OnAfterUnloadingDone(From,Event,To)
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