-------------------------------------------------------------------------
-- AmmoTruck 100 - NTTR - Basic
-------------------------------------------------------------------------
-- Documentation
-- 
-- AMMOTRUCK: https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.AmmoTruck.html
-- 
-------------------------------------------------------------------------
-- Join the game master slot. The howitzers are firing at the red
-- bunkers. When close to out of ammunition, trucks will drive towards
-- the artillery pieces and reload them.
-------------------------------------------------------------------------
-- Date: November 2022
-------------------------------------------------------------------------


BASE:TraceOn()
BASE:TraceClass("AMMOTRUCK")

local truckset = SET_GROUP:New():FilterCoalitions("blue"):FilterActive(true):FilterCategoryGround():FilterPrefixes("Truck"):FilterStart()
local ariset = SET_GROUP:New():FilterCoalitions("blue"):FilterActive(true):FilterCategoryGround():FilterPrefixes("Artillery"):FilterStart()

local ammotruck = AMMOTRUCK:New(truckset,ariset,coalition.side.BLUE,"Logistics",ZONE:FindByName("HomeZone"))
ammotruck.waitingtime = 60*15
ammotruck.unloadtime = 60*10
ammotruck.monitor = -30
ammotruck.ammothreshold = 5
ammotruck.usearmygroup = true

--Truck has been sent off:
 function ammotruck:OnAfterRouteTruck(From, Event, To, Truckdata, Aridata)
   local m = MESSAGE:New("Truck "..Truckdata.name.." on the way!",15,"AmmoTruck"):ToBlue()
 end


--Truck has arrived:
 function ammotruck:OnAfterTruckArrived(From, Event, To, Truckdata)
   local m = MESSAGE:New("Truck "..Truckdata.name.." arrived!",15,"AmmoTruck"):ToBlue()
 end 


--Truck is returning home:
 function ammotruck:OnAfterTruckReturning(From, Event, To, Truckdata)
   local m = MESSAGE:New("Truck "..Truckdata.name.." returning!",15,"AmmoTruck"):ToBlue()
 end  


--Truck is arrived at home:
 function ammotruck:OnAfterTruckHome(From, Event, To, Truckdata)
   local m = MESSAGE:New("Truck "..Truckdata.name.." arrived home!",15,"AmmoTruck"):ToBlue()
 end 


local trucks = SPAWN:New("Truck")
  :InitLimit(5,0)
  :InitRandomizePosition(true,100,10)
  :SpawnScheduled(15,0)
