

BASE:TraceOn()
BASE:TraceClass("PLAYERTASKCONTROLLER")

_SETTINGS:SetPlayerMenuOn()
_SETTINGS:SetA2G_LL_DMS()
_SETTINGS:SetA2A_BULLS()

local taskmanager = PLAYERTASKCONTROLLER:New("Air to Ship",coalition.side.BLUE,PLAYERTASKCONTROLLER.Type.A2S)
taskmanager:SetMenuName("Coast Guard")
taskmanager:SetShowRadioInfoMenu(true)
taskmanager:SetMenuOptions(true,10)
taskmanager:SetEnableUseTypeNames()
taskmanager:SetupIntel("Recce")
taskmanager:AddAcceptZone(ZONE:New("Defense Zone"))
local Port = 5010
local Voice = MSRS.Voices.Google.Wavenet.en_GB_Wavenet_D
local Backend = MSRS.Backend.GRPC
local Coordinate = AIRBASE:FindByName(AIRBASE.MarianaIslands.Andersen_AFB):GetCoordinate()
taskmanager:SetSRS({130,230},{radio.modulation.AM,radio.modulation.AM},PathToSRS,Gender,Culture,Port,Voice,Volume,PathToGoogleKey,AccessKey,Coordinate,Backend)
taskmanager:SetSRSBroadcast({30,243},{radio.modulation.AM,radio.modulation.AM})

function taskmanager:OnAfterTaskAdded(From,Event,To,Task)
  local task = Task -- Ops.PlayerTask#PLAYERTASK
  local target = task:GetTarget() -- Ops.Target#TARGET
  if target:GetCategory() == TARGET.Category.NAVAL then
    MESSAGE:New("Naval Target Added!",15,"INFO"):ToBlue()
  else
    MESSAGE:New("Other Target Added!",15,"INFO"):ToBlue()
  end
end