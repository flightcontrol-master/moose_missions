---
-- AUFTRAG: Orbit Group
--
-- A Reaper drone is assigned to orbit overhead a speed boat on its way near the coast,
-- as we suspect some smuggler activities.
-- 
-- We will offset the orbit a bit in ordner not to arousea too much attention
-- of the boat crew.
---

-- Create flight group object.
local reaper=FLIGHTGROUP:New("Reaper Charlie")

-- Speed boat group.
local speedboat=GROUP:FindByName("Speed Boat Charlie")
speedboat:Activate()

-- Create a mission to orbit overhead the speed boat.
local mission=AUFTRAG:NewORBIT_GROUP(speedboat, 5000, 150, nil, nil, {x=5, y=5})

-- Assign mission to the UAV.
reaper:AddMission(mission)