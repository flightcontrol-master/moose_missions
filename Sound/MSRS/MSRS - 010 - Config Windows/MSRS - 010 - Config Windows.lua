----
-- MSRS: Config Windows
--
-- This is a simple demo mission that shows how to use the MSRS class to provide text-to-speech via SRS.
-- Therefore, you need to have the SRS cliend and server installed and running on your system.
-- 
-- The parameters are taken from a config file "Moose_MSRS.lua", which is included in the demo directory.
-- You need to copy this file to your "Saved Games/DCS/Config/" directory and adjust the necessary parameters.
-- In particular, you need to set the path where SRS is installed on your system.
-- Also the voice used will be "Microsoft Hazel Desktop". You need to either install that on your windows 
-- system or change it to a voice you have installed.
-- The config file is automatically loaded when Moose is loaded. So you do not need to worry about it.
-- 
-- First, we create a MSRS instance, which will transmit on 305 MHz AM.
-- The text is then broadcasted after 5 seconds.
-- 
-- You can either use the SRS awacs overlay or just into the F/A-18 Hornet client to listen in on the transmission.
--- 


-- Create a new MSRS instance. Frequency is 305 MHz AM(=0). 
-- The first parameter (nil) is the SRS installation path. This is taken from the Moose_MSRS.lua config file.
local msrs=MSRS:New(nil, 305.00, 0)

-- Broadcast text after 5 seconds.
msrs:PlayText("Hello World, this is the Moose simple radio text-to-speech class speaking.", 5)
