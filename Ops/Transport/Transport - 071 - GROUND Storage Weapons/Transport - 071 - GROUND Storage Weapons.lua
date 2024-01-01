---
-- STORAGE: Weapons
-- 
-- The airbase at Batumi ran out of weapons.
-- 
-- A group of two trucks from the nearby FARP Berlin is ordered to transport 14 AIM-120C missiles 
-- and 9 MK-82 bombs. The FARP initially has 100 AIM-120Cs and 200 MK-82s in store.
-- 
-- Each truck can load ~1140 kg of cargo at once. So both have 2280 kg cargo capacity combined.
-- As explained below, the group will need three runs to transport all the cargo.
-- 
-- NOTE that the weight of the weapons cannot be retrieved from the DCS API. 
-- Therefore it has to be specified manually as input parameter:
-- 
-- * For the AIM-120C, we set a weight of 162 kg. So in total 2268 kg need to be transported.
--   Each carrier element/unit can load seven missiles (1140/162=7.037). So all 14 missiles can
--   be loaded into both carriers and can be transported in one go. 
-- 
-- * For the MK-82, we use a weight of 230 kg. So in total 2070 kg need to be transported.
--   Note that even though 2070 is less then 2280, which suggests that the cargo can be transported
--   by both carriers in one go, each carrier can only load four bombs (4*230=920 but 5*230=1150).
--   Hence, in one run, the group can only transport 8 bombs and one additonal run is needed to transport
--   the last one.
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
-- Note that for weapons/equipment, we need to specify the weight of each item as parameter.
transport:AddCargoStorage(berlinStorage, batumiStorage, ENUMS.Storage.weapons.missiles.AIM_120C, 14, 162)
transport:AddCargoStorage(berlinStorage, batumiStorage, ENUMS.Storage.weapons.bombs.Mk_82, 9, 230)

-- Create armygroup object.
local truck=ARMYGROUP:New("Truck M939 Bravo")

-- Assign transport to truck.  
truck:AddOpsTransport(transport)



--- Function to report the current amount of fuel at Berlin and Batumi
local function reportStorage()
  local text=string.format("Current storage amount:\n")
  local text=string.format("Berlin has %d AIM-120Cs and %d MK-82s\n", berlinStorage:GetItemAmount(ENUMS.Storage.weapons.missiles.AIM_120C), berlinStorage:GetItemAmount(ENUMS.Storage.weapons.bombs.Mk_82))
  text=text..string.format("Batumi has %d AIM-120Cs and %d MK-82s",   batumiStorage:GetItemAmount(ENUMS.Storage.weapons.missiles.AIM_120C), batumiStorage:GetItemAmount(ENUMS.Storage.weapons.bombs.Mk_82))
  MESSAGE:New(text, 300):ToAll():ToLog()
end

-- Report initial storage.
reportStorage()

--- Function called after truck has loaded a batch of cargo.
function truck:OnAfterLoadingDone(From, Event, To)
  reportStorage()
end

--- Function called after truck has unloaded a batch of cargo.
function truck:OnAfterUnloadingDone(From, Event, To)
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