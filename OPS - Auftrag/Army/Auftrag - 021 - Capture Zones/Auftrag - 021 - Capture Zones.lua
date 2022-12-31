---
-- AUFTRAG: Capture Zone
-- 
-- A IFV Bradley and an MBT Abrams are located near Mozdok airbase.
-- 
-- They are assigned to capture multiple zones nearby.
-- 
-- In some zones, there are enemy units, which have ROE="Weapon Hold".
-- The blue forces will engage all targets.
-- 
-- The blue forces will always try to capture the nearest red or neutral
-- zone.
-- 
-- Once all six zones are captured, blue will return to their initial
-- position.
-- 
-- NOTE that the group does not rely on its detection. It will know
-- all enemy position via the eye of Sauron.
---

-- Create a capture zones.
local opszone1=OPSZONE:New("Alpha-1")
local opszone2=OPSZONE:New("Alpha-2")
local opszone3=OPSZONE:New("Alpha-3")
local opszone4=OPSZONE:New("Alpha-4")
local opszone5=OPSZONE:New("Alpha-5")
local opszone6=OPSZONE:New("Alpha-6")


-- Create a SET_OPSGROUP of the capture zones.
local opszones=SET_OPSZONE:New():FilterPrefixes("Alpha"):FilterOnce()

-- Start all opszones in the SET.
opszones:Start()


-- Create a new CAPTUREZONE mission. Mission is a success once the BLUE coalition captures it.
local mission=AUFTRAG:NewCAPTUREZONE(opszones, coalition.side.BLUE)


-- Create a new ARMYGROUP object.
local bradley=ARMYGROUP:New("Bradley Alpha-1")

-- Assign mission to Bradley.
bradley:AddMission(mission)

local abrams=ARMYGROUP:New("Abrams Alpha-1")

-- Assign mission to Abrams.
abrams:AddMission(mission)
