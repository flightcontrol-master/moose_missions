
-- Name: CHIEF - 055 - Transport Troops OPSZONE
-- Author: Wingthor
-- Date Created: 20 Aug 2023
-- Code writen in VSC ide and annotation with respect to EmmyLua, comments might look strange in Eclipe IDE.
-- AUFTRAG: using the CHIEF Transport Troops, Cargo and handle strategic zone.

--- This mission ilustrate how to make a CHIEF take availabe resources, and transport troops and cargo by air.
--- You maybe need to wait for about two minutes before things happens
--- As per current date you might expirience helicopter landing in strange and bizarre places. Not sure if it is a DCS or Moose issue. Hopefully it will be fixed. Alternative you can put the zone in a flat clear area.

---@class BASE tuen on tracing of relevant class
BASE:TraceLevel(2)
---@class BASE tuen on tracing of relevant class
BASE:TraceClass("OPSZONE")
---@class BASE tuen on tracing of relevant class
BASE:TraceClass("AUFTRAG")
---@class BASE tuen on tracing of relevant class
BASE:TraceClass("CHIEF")

AUFTRAG.verbose = 3
OPSZONE.verbose = 3
CHIEF.verbose = 3


-- Static cargo objects.
-- NOTE that
-- * We need the "UNIT NAME here (not the "NAME").
-- * It has to have the tick box "CAN BE CARGO" activated.
local staticAmmo = STATIC:FindByName("Static Ammo-1")
local staticBarrels = STATIC:FindByName("Static Barrels-1")
local staticOiltank = STATIC:FindByName("Static Oiltank-1")

local staticAmmo_CHIEF = STATIC:FindByName("Static Ammo_CHIEF")
local staticBarrels_CHIEF = STATIC:FindByName("Static Barrels_CHIEF")
local staticOiltank_CHIEF = STATIC:FindByName("Static Oiltank_CHIEF")
-- Zone where to drop off the cargo.
-- NOTE that this has to be a zone defined in the ME!
-- local dropsZone = ZONE:New("Drop Zone")


---@class AIRWING Creates and AIRWING
local myAirWing = AIRWING:New("BatumiWarehouse", "BatumiAB")
myAirWing:Start()

---@class SQUADRON Creates and SQUADRON of HeliTransporters
local heliSquadron = SQUADRON:New("Rotary_CHIEF", 4, "Taxi")
heliSquadron:AddMissionCapability({ AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.OPSTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT })
heliSquadron:SetAttribute(GROUP.Attribute.AIR_TRANSPORTHELO)

---Creates a Payload, REQUIRED
myAirWing:NewPayload(GROUP:FindByName("Rotary_CHIEF"), 20, { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.OPSTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT })

-- Add the Squadron to the AIRWING (Warehouse)
myAirWing:AddSquadron(heliSquadron)

---@class BRIGADE Creates a brigade of troops to be availabe for the CHIEF
local myBrigade = BRIGADE:New("BatumiWarehouse", "Brigade Batumi")
myBrigade:Start()

---@class PLATOON Creating a PLATOON
local myPlatoon = PLATOON:New("BlueInf", 100, "Blue Infantry")
myPlatoon:AddMissionCapability({ AUFTRAG.Type.PATROLZONE, AUFTRAG.Type.ONGUARD, AUFTRAG.Type.GROUNDATTACK }, 70)
myPlatoon:SetAttribute(GROUP.Attribute.GROUND_INFANTRY)
myPlatoon:SetGrouping(7)

-- Adding the PLATOON to the AIRWING
myBrigade:AddPlatoon(myPlatoon)

---@class CHIEF Creates a CHIEF. Chief also have a COMMANDER, you get get the COMMANDER by CHIEF:GetCommander()
myChief = CHIEF:New("blue", nil, "Birdie Bro")
-- Starts the CHIEF Finite State Machine
myChief:Start()

-- Adding the AIRWING, and BRIGADE to the CHIEF
myChief:AddAirwing(myAirWing)
myChief:AddBrigade(myBrigade)
myChief:SetStrategy(CHIEF.Strategy.AGGRESSIVE)
-- So we can Tactics in the Mision
myChief:SetTacticalOverviewOn()


-- Creates a resource for the CIEF, we will use this when creating the strategic zone
local ResourceEmpty, ResourceGuardInfantry = myChief:CreateResource(AUFTRAG.Type.ONGUARD, 7, 14, GROUP.Attribute.GROUND_INFANTRY)
local ResourceOccupied, ResourceAttackInfantry = myChief:CreateResource(AUFTRAG.Type.ONGUARD, 7, 14, GROUP.Attribute.GROUND_INFANTRY)

myChief:AddTransportToResource(ResourceGuardInfantry, 1, 1,
    { GROUP.Attribute.AIR_TRANSPORTHELO, GROUP.Attribute.GROUND_APC })

myChief:AddTransportToResource(ResourceAttackInfantry, 1, 1,
    { GROUP.Attribute.AIR_TRANSPORTHELO, GROUP.Attribute.GROUND_APC })


---@type table<string,OPSZONE> a table (dictinary) to hold the OPSZONEs
local opsZoneTable = {}

---@class OPSZONE A Random place on the map. You can change the position of this in the Mission Editor.
local blueStrategicZone = OPSZONE:New(ZONE:New("BlueOpszone1"), coalition.side.RED)
blueStrategicZone:SetCaptureThreatlevel(10)
blueStrategicZone:SetCaptureTime(120)
-- Starts the OPSZONE Finite State Machine (FSM) to capture EVENT OnAfterCaptured.
blueStrategicZone:Start()
-- Add the OPSZONE to a table so we can reduce code lines later.
opsZoneTable[blueStrategicZone:GetName()] = blueStrategicZone
-- Adding the strategic zone to the CHIEF, also defines prio, importance, which defines the order the strategic zone will be occupied. Also assign the resource availabe for CHIEF to use in the OPSZONE. Mark the AddStrategicZone
-- returns two values. The latter is used when assigning transport to the resource.
myChief:AddStrategicZone(blueStrategicZone, 2, 3, ResourceOccupied, ResourceEmpty)


---@class OPSZONE Kobuletti Airort a second strategic zone. 
local blueStrategicZoneKobuletti = OPSZONE:New(ZONE:New("BlueOpszone2"), coalition.side.RED)
blueStrategicZoneKobuletti:SetCaptureThreatlevel(10)
blueStrategicZoneKobuletti:SetCaptureTime(120)
-- Starts the OPSZONE Finite State Machine (FSM) to capture EVENT OnAfterCaptured.
blueStrategicZoneKobuletti:Start()
-- Add the OPSZONE to a table so we can reduce code lines later.
opsZoneTable[blueStrategicZone:GetName()] = blueStrategicZoneKobuletti
myChief:AddStrategicZone(blueStrategicZoneKobuletti, 50, 2, ResourceOccupied, ResourceEmpty)

---@param opzone OPSZONE
for _, opsZone in pairs(opsZoneTable) do
    ---@param self OPSZONE Hidden self
    ---@param From string
    ---@param Event string
    ---@param To string
    ---@param Coalition number
    opsZone.OnAfterCaptured = function(self, From, Event, To, Coalition)
        -- Add a line to the dcs log to verify function is actually called
        BASE:I(string.format("%s was captured", opsZone:GetName()))
        -- Check coaltion side
        if Coalition == coalition.side.BLUE then 
            -- differ the two zones since mission created will be respective
            if opsZone:GetName() == "BlueOpsZone1" then
                -- Create mission to transport barrels. This has lowest prio (highest opsZone) so is done last.
                local missionBarrels_CHIEF = AUFTRAG:NewCARGOTRANSPORT(staticBarrels_CHIEF, opsZone:GetZone())
                missionBarrels_CHIEF:SetPriority(70)
                -- Create mission to transport ammo. This has the highest prio (lowest opsZone) so is done first.
                local missionAmmo_CHIEF = AUFTRAG:NewCARGOTRANSPORT(staticAmmo_CHIEF, opsZone:GetZone())
                missionAmmo_CHIEF:SetPriority(30)
                -- Create mission to transport an oil tank. This has medium prio and is done after the ammo but before the barrels.
                local missionOiltank_CHIEF = AUFTRAG:NewCARGOTRANSPORT(staticOiltank_CHIEF, opsZone:GetZone())
                missionOiltank_CHIEF:SetPriority(50)

                myChief:AddMission(missionAmmo_CHIEF)
                myChief:AddMission(missionBarrels_CHIEF)
                myChief:AddMission(missionOiltank_CHIEF)
            else
                -- Create mission to transport an oil tank. This has medium prio and is done after the ammo but before the barrels.
                local missionOiltank = AUFTRAG:NewCARGOTRANSPORT(staticOiltank, opsZone:GetZone())
                missionOiltank:SetPriority(50)
                -- Create mission to transport ammo. This has the highest prio (lowest opsZone) so is done first.
                local missionAmmo = AUFTRAG:NewCARGOTRANSPORT(staticAmmo, opsZone:GetZone())
                missionAmmo:SetPriority(30)
                -- Create mission to transport barrels. This has lowest prio (highest opsZone) so is done last.
                local missionBarrels = AUFTRAG:NewCARGOTRANSPORT(staticBarrels, opsZone:GetZone())
                missionBarrels:SetPriority(70)

                -- Assign mission to CHIEF.
                myChief:AddMission(missionAmmo)
                myChief:AddMission(missionBarrels)
                myChief:AddMission(missionOiltank)
            end

        end

    end
end

