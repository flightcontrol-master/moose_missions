---
-- BRIGADE: Ground Attack
-- 
-- A brigade at Anapa consists of a Platoon of TPz Fuchs APCs.
-- 
-- Up to five groups will be spawned to do "nothing" in the spawn
-- zone of the brigade warehouse.
-- 
-- After two minutes, two "on-guard" missions are launched at nearby zones.
-- The groups that are spawned will be the first choice for executing the mission.
-- 
-- Once the first "on-guard" mission is executed, a ground attack mission to attack an
-- enemy IFV is added to the brigade. The selected group will be the one that is 
-- "on-guard" in the patrol zone Alpha as this group is nearest to the enemy
-- (and no other assets more capable to execute ground attack missions are available).
-- 
-- The TPz does not stand a chance agains the IFV however, and will be destroyed.
-- The mission is repeated 5 times if it fails. The next group to run the attack is
-- then selected form the groups that are on the "do nothing" mission.
-- 
-- This mission demonstrates how spawned assets are used rather than spawning new ones
-- from the warehouse.
-- 
-- Note that not in all cases missions are paused for other missions!
-- 
-- If groups are on a nothing mission, they are preferred for all other missions they are
-- capable of since they are spawned. However, the selection process is more complicated
-- and involves also checks how performant an asset is for a given mission.
-- 
-- Groups on a patrol zone or on-guard mission are considered for ground attack or arty missions.
-- After the attack mission is over, they will resume their previous mission.
---

-- Zones.
local ZoneAnapaSpawn=ZONE:FindByName("Warehouse Anapa Spawn"):DrawZone()
local ZonePatrolAlpha=ZONE:FindByName("Patrol Alpha"):DrawZone()
local ZonePatrolBravo=ZONE:FindByName("Patrol Bravo"):DrawZone()

-- Platoon of Transportpanzer Fuchs APCs capable of patrol, on-guard and ground attack missions.
local PlatoonFuchs=PLATOON:New("TPz Fuchs Template", 10, "Platoon APC Fuchs Alpha")
PlatoonFuchs:AddMissionCapability({AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ONGUARD, AUFTRAG.Type.GROUNDATTACK}, 70)

-- Brigade at Kobuleti
local BrigadeAnapa=BRIGADE:New("Warehouse Anapa", "Brigade Anapa") --Ops.Brigade#BRIGADE
BrigadeAnapa:SetSpawnZone(ZoneAnapaSpawn)
BrigadeAnapa:Start()

-- Add platoon.
BrigadeAnapa:AddPlatoon(PlatoonFuchs)


-- Mission to do nothing in the spawn zone of the warehouse.
local missionNothing=AUFTRAG:NewNOTHING(ZoneAnapaSpawn)
missionNothing:SetRequiredAssets(1, 5)
 
-- Mission to be on-guard in zone Patrol Alpha. Mission is started after 2 min.
local missionOnGuardAlpha=AUFTRAG:NewONGUARD(ZonePatrolAlpha:GetRandomCoordinate(nil, nil, {land.SurfaceType.LAND}))
missionOnGuardAlpha:SetTime(120)

-- Mission to be on-guard in zone Patrol Bravo. Mission is started ASAP.
local missionOnGuardBravo=AUFTRAG:NewONGUARD(ZonePatrolBravo:GetRandomCoordinate(nil, nil, {land.SurfaceType.LAND}))

-- Add missions to brigade.
BrigadeAnapa:AddMission(missionNothing) 
BrigadeAnapa:AddMission(missionOnGuardAlpha)
BrigadeAnapa:AddMission(missionOnGuardBravo)
  
-- Function called after mission guard alpha is executed.
function missionOnGuardAlpha:OnAfterExecuting(From, Event, To)

  -- Target group.
  local targetGroup=GROUP:FindByName("BTR-82A Alpha-1")
  
  -- Debug message.
  local text=string.format("Attacking Target %s", targetGroup:GetName())
  MESSAGE:New(text, 360):ToAll():ToLog()
  
  -- Missin to attack target. We go off-road and repeat the mission up to five times.
  local missionGroundAttack=AUFTRAG:NewGROUNDATTACK(targetGroup)
  missionGroundAttack:SetFormation(ENUMS.Formation.Vehicle.OffRoad)
  missionGroundAttack:SetRepeatOnFailure(5)
  
  -- Add mission to brigade.
  BrigadeAnapa:AddMission(missionGroundAttack)
end
