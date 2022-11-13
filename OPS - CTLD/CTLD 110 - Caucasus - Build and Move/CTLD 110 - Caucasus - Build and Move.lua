-------------------------------------------------------------------------
-- CTLD 110 - Caucasus - Build and Move
-------------------------------------------------------------------------
-- Documentation
-- 
-- CTLD: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.CTLD.html
-- 
-------------------------------------------------------------------------
-- Join a Helicopter. Use the F10 menu to request crates and/or troops. 
-- Fly over to the drop zone at the far end of the airport and unload.
-- We'll auto create a MOVE type zone and the unloaded troops & vehicles
-- will attack REDFOR.
-------------------------------------------------------------------------
-- Date: November 2022
-------------------------------------------------------------------------

_SETTINGS:SetPlayerMenuOff()

local my_ctld = CTLD:New(coalition.side.BLUE,{"Helicargo"},"Lufttransportbrigade I")
my_ctld.forcehoverload = false
my_ctld.movetroopsdistance = 6000
my_ctld.dropcratesanywhere = true
my_ctld.debug = false
my_ctld.buildtime = 30
my_ctld:__Start(5)

-- generate generically loadable stuff
my_ctld:AddTroopsCargo("Infantry",{"Infantry6"},CTLD_CARGO.Enum.TROOPS,6,80,nil,"Troops")
my_ctld:AddCratesCargo("Humvee",{"Humvee"},CTLD_CARGO.Enum.VEHICLE,1,100,nil,"Vehicles")

-- generate zone types
my_ctld:AddCTLDZone("Loadzone",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true) -- Note: since there are no blue flares, this will be a white flare when requested.
my_ctld:AddCTLDZone("Dropzone",CTLD.CargoZoneType.DROP,SMOKECOLOR.Red,true,true)
local dropzone = ZONE:FindByName("Dropzone"):DrawZone(-1,{0,0,1},1,{0,0,1},0.25,1)

-- update unit capabilities for testing
my_ctld:UnitCapabilities("SA342L", true, true, 1, 6, 12, 1000)

-- Cache new MOVE zones here
local RedMoveZones = {}

function BuildMoveZones(Group,Unit,Troops)
  -- find baddies near by with a ZONE filter
  local zone = ZONE_GROUP:New(Group:GetName(),Group,6000)
  local enemyset = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryGround():FilterZones({zone}):FilterOnce()
  if enemyset:Count() > 0 then
    MESSAGE:New(string.format("Found %d enemy group(s) nearby!", enemyset:Count()),15):ToBlue()
    for _,_redgrp in pairs(enemyset.Set) do
      local redgrp = _redgrp -- Wrapper.Group#GROUP
      if not RedMoveZones[redgrp:GetName()] then
        -- baddies found, add zone around them
        local zonename = "Baddies-"..math.random(1,10000)
        local redzone = ZONE_GROUP:New(zonename,redgrp,200)
        redzone:DrawZone(-1,{1,0.6,0},1,{1,0.6,0},0.25,4)
        my_ctld:AddCTLDZone(zonename,CTLD.CargoZoneType.MOVE,SMOKECOLOR.Orange,true,false)
        RedMoveZones[redgrp:GetName()] = redzone
      end
    end
  end
end

-- We're using OnBefore ... to add a MOVE zone
function my_ctld:OnBeforeTroopsDeployed(From,Event,To,Group,Unit,Troops)
  BuildMoveZones(Group,Unit,Troops)
  return self
end

-- We're using OnBefore ... to add a MOVE zone
function my_ctld:OnBeforeCratesBuild(From,Event,To,Group,Unit,Vehicle)
  BuildMoveZones(Group,Unit,Vehicle)
  return self
end
