-------------------------------------------------------------------------
-- CTLD 120 - Caucasus - Chinook Test Mission
-------------------------------------------------------------------------
-- Documentation
-- 
-- CTLD: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.CTLD.html
-- 
-------------------------------------------------------------------------
-- Join a Chinook. Use the F10 menu to request crates and/or troops. 
-- Use the F8 Ground Crew Menu to create dynamic carfo and load it.
-- Fly over to the drop zone at the far end of the airport and unload.
-- Use the F10 menu to build vehicles out of crates.
-------------------------------------------------------------------------
-- Date: 17 Aug 2024
-------------------------------------------------------------------------


_SETTINGS:SetPlayerMenuOff()

local my_ctld = CTLD:New(coalition.side.BLUE,{"Helicargo","CH.47"},"Lufttransportbrigade I")
my_ctld.useprefix = true
my_ctld.dropcratesanywhere = true
my_ctld.forcehoverload = false -- Chinook must-have option
my_ctld.enableHercules = false
my_ctld.allowcratepickupagain = true
my_ctld.nobuildinloadzones = true -- Chinook must-have option
my_ctld.movecratesbeforebuild = true -- Chinook must-have option
my_ctld.movetroopstowpzone = true
my_ctld.enableChinhookGCLoading = true -- Chinook must-have option
my_ctld.hoverautoloading = false -- Chinook must-have option
my_ctld.enableslingload = true -- Chinook must-have option
my_ctld.pilotmustopendoors = true
my_ctld.ChinookTroopCircleRadius = 5 -- Radius for troops dropping in a nice circle. Adjust to your planned squad size for the Chinook.
my_ctld:__Start(5)

-- generate generically loadable stuff
my_ctld:AddTroopsCargo("Anti-Tank Small (3)",{"ATS"},CTLD_CARGO.Enum.TROOPS,3,80,nil,"Troops")
my_ctld:AddTroopsCargo("Anti-Air (4)",{"AA","AA2"},CTLD_CARGO.Enum.TROOPS,4,80,nil,"Troops")
my_ctld:AddTroopsCargo("Marines (10)",{"Marines"},CTLD_CARGO.Enum.TROOPS,10,80,nil,"Troops")
my_ctld:AddCratesCargo("Humvee (2)",{"Humvee"},CTLD_CARGO.Enum.VEHICLE,2,1000,nil,"Vehicles")
my_ctld:AddCratesCargo("Forward Ops Base (4)",{"FOB"},CTLD_CARGO.Enum.FOB,4,1000,nil,"FOB")

-- generate zone types
my_ctld:AddCTLDZone("Loadzone",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true) -- Note: since there are no blue flares, this will be a white flare when requested.
my_ctld:AddCTLDZone("Dropzone",CTLD.CargoZoneType.DROP,SMOKECOLOR.Red,true,true)
my_ctld:AddCTLDZone("Movezone",CTLD.CargoZoneType.MOVE,SMOKECOLOR.Orange,false,false)

function my_ctld:OnAfterCratesPickedUp(From,Event,To,Group,Unit,Cargo)
  MESSAGE:New("Crates picked up by "..Unit:GetPlayerName(),10,"CTLD"):ToBlue()
end

function my_ctld:OnAfterCratesDropped(From,Event,To,Group,Unit,Cargotable)
  MESSAGE:New("Crates dropped by "..Unit:GetPlayerName(),10,"CTLD"):ToBlue()
end
