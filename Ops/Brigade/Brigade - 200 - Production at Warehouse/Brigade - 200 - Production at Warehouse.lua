---
-- BRIGADE: Production at Warehouse
-- 
-- A tech combine (warehouse) near Senaki is producing IFV Marder vehicles.
-- Each produced group is spawned and driving by itself to the brigade at Senaki,
-- where it is added to a platoon.
-- 
-- The platoon initially has no assets at all. Once five Marders are in stock,
-- they will go on a patrol mission at a nearby zone.
---

-- Platoon of IFV Marder capable of patrol missions.
local PlatoonMarder=PLATOON:New("IFV Marder Template", 0, "Platoon IFV Marder Alpha")
PlatoonMarder:AddMissionCapability({AUFTRAG.Type.PATROLZONE}, 70)

-- Brigade at Kobuleti
local BrigadeSenaki=BRIGADE:New("Warehouse Senaki", "Brigade Senaki") --Ops.Brigade#BRIGADE
BrigadeSenaki:SetSpawnZone(ZONE:FindByName("Warehouse Senaki Spawn Zone"))
BrigadeSenaki:Start()

-- Add platoon.
BrigadeSenaki:AddPlatoon(PlatoonMarder)

-- Mission that requires 5 asset groups.
local mission=AUFTRAG:NewPATROLZONE(ZONE:FindByName("Refuelling Alpha"))
mission:SetRequiredAssets(5)
BrigadeSenaki:AddMission(mission)


-- Tech Combine Producing 
local TechCombineAlpha=WAREHOUSE:New("Tech Combine Alpha", "Tech Combine Alpha")
TechCombineAlpha:Start()

-- Calling this function addes an asset to the Tech Combine and sends a request from the Brigade.
-- Note that the "assignment" of both the :AddAsset() and the :AddRequest() functions need to be the name of the Platoon where this asset will be added to.
local function Production()
  TechCombineAlpha:AddAsset(GROUP:FindByName("IFV Marder Template"), 1, nil, nil, nil, nil, nil, nil, PlatoonMarder:GetName())  
  TechCombineAlpha:AddRequest(BrigadeSenaki, WAREHOUSE.Descriptor.GROUPNAME, "IFV Marder Template", 1, nil, nil, nil, PlatoonMarder:GetName())
end

-- Produce a Marder every 60 seconds (starting after 5 sec).
TIMER:New(Production):Start(5, 60)


-- Count total number of assets.
local function countassets()
  local N=BrigadeSenaki:CountAssets()
  MESSAGE:New(string.format("Brigrade assets N=%d", N), 5):ToAll()
end  
TIMER:New(countassets):Start(5, 10)
