@ECHO OFF
wpeinit
cd\
title OSDCloud 0823
PowerShell -Nol -C Initialize-OSDCloudStartnet
@ECHO OFF
ECHO Start-OSDCloud
iex (irm "https://raw.githubusercontent.com/adoonrat/Autopilot/main/Start-OSDCloud.ps1")
