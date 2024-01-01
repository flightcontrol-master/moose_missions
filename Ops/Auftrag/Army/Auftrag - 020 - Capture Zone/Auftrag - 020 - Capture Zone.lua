---
-- AUFTRAG: Capture Zone
-- 
-- A IFV Bradley is located near Mozdok airbase.
-- It is assigned to capture a zone nearby.
-- 
-- In the zone, there are three BMP-80s, which have ROE=Weapon Hold.
-- The Bradley will engage all three targets. Once they are destroyed,
-- it will return to its initial position.
---


-- Create a new ARMYGROUP object.
local bradley=ARMYGROUP:New("Bradley Alpha-1")

-- Create a capture zone and start it.
local opszone=OPSZONE:New("Alpha-1")
opszone:Start()


-- Create a new CAPTUREZONE mission. Mission is a success once the BLUE coalition captures it.
local mission=AUFTRAG:NewCAPTUREZONE(opszone, coalition.side.BLUE)


-- Assign mission to Bradley.
bradley:AddMission(mission)


