---
-- Auftrag - Armor Attack
-- 
---

-- Create a new ARMYGROUP object.
local armygroup=ARMYGROUP:New("Blue Tanks")
armygroup:SetDefaultFormation(ENUMS.Formation.Vehicle.OnRoad)

-- We set the weapon min/max ranges in nautical miles (NM). Target needs to be not closer than 2 km.
armygroup:AddWeaponRange(0,UTILS.KiloMetersToNM(2))

local mission = AUFTRAG:NewARMORATTACK(GROUP:FindByName("Red Tanks"),UTILS.KmphToKnots(20),"Vee")

-- Give mission to commander.
armygroup:AddMission(mission)
