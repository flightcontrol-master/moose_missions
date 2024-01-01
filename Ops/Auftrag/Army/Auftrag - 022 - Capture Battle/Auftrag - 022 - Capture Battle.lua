---
-- AUFTRAG: Capture Battle
-- 
-- Red and blue forces are batteling for multiple zones near the Mozdok area.
-- 
-- Both forces have one IFV and MBT at their disposal to capture six zones.
-- 
-- To capture a zone, a coaliton must own it for at least 2 minutes.
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

-- Set capture time. A coalition must be present in the zone for at least 120 seconds to capture it.
opszones:ForEachZone(
function (_opszone)
  local opszone=_opszone --Ops.OpsZone#OPSZONE
  opszone:SetCaptureTime(120)
end
)


---
-- BlueFor
---

-- Create a new CAPTUREZONE mission. Mission is a success once the BLUE coalition captures all zones.
local missionBlue=AUFTRAG:NewCAPTUREZONE(opszones, coalition.side.BLUE)

-- We set the ROE to OpenFire so the units will already engage enemies if they are not yet in the capture zone.
missionBlue:SetROE(ENUMS.ROE.OpenFire)


-- Create a new ARMYGROUP object.
local bradley=ARMYGROUP:New("Bradley Alpha-1")

-- Assign mission to Bradley.
bradley:AddMission(missionBlue)

-- Create ARMYGROUP from Abrams.
local abrams=ARMYGROUP:New("Abrams Alpha-1")

-- Assign mission to Abrams.
abrams:AddMission(missionBlue)


---
-- RedFor
---

-- Create a new CAPTUREZONE mission. Mission is a success once the RED coalition captures all zones.
local missionRed=AUFTRAG:NewCAPTUREZONE(opszones, coalition.side.RED)

-- We set the ROE to OpenFire so the units will already engage enemies if they are not yet in the capture zone.
missionRed:SetROE(ENUMS.ROE.OpenFire)

-- Create a new ARMYGROUP object.
local btr82=ARMYGROUP:New("BTR-82A Alpha-1")

-- Assign mission to Bradley.
btr82:AddMission(missionRed)

-- Create ARMYGROUP from Abrams.
local t80=ARMYGROUP:New("T-80 Alpha-1")

-- Assign mission to Abrams.
t80:AddMission(missionRed)
