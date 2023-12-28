-- This demo mission will play an external audio file.
-- This is a file which is not part of the .miz file.
-- Save the file Hello-world.ogg to your Missions folder,
-- e.g. C:\Users\<YourUserName>\Saved Games\DCS.openbeta\Missions
-- Enter the A-10CII and listen to the radio.
-- If you don't own A-10CII you have to change the mission to use another aircraft.

-- Check dcs.log if something is not working:
BASE:TraceClass("MSRS")
BASE:TraceClass("SOUNDFILE")
BASE:TraceLevel(3)
BASE:TraceOnOff( true )

FileName = "Hello-world.ogg"
FolderPath = lfs.writedir() .. 'Missions'
Duration=nil -- Will use 3 seconds as default
UseSrs=true
InstallPathSrs=nil -- This will use the default installation path of SRS

-- If you did't install SRS into the default path uncomment and change the line below.
--InstallPathSrs = "G:\\Spiele\\DCS\\Tools\\DCS-SimpleRadio-Standalone"

local soundfile=SOUNDFILE:New(FileName, FolderPath, Duration, UseSrs)
local msrs=MSRS:New( InstallPathSrs, 251, radio.modulation.AM)

local function msg()
  MESSAGE:New( "I try to play the external sound file now!" ):ToAll():ToLog()
  msrs:PlaySoundFile(soundfile)
end

-- Use a timer to delay the transmission 2 seconds after script is executeed.
-- Repeat transmission every 10 seconds.
TIMER:New( msg ):Start(2, 10)
