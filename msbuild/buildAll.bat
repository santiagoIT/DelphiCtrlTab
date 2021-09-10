@echo off

SET batPath=%~dp0..

echo BATPATH: %batPath%




REM MS BUILD
SET MSB=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin
IF NOT EXIST "%MSB%" SET MSB=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin
IF NOT EXIST "%MSB%" SET MSB=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin

REM Delphi 11 - Alexandria
SET BDSVERSION=22.0
SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%
IF NOT EXIST "%BDS%" SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%

SET BDSCOMMONDIR=C:\Users\Public\Documents\Embarcadero\Studio\%BDSVERSION%
"%MSB%\MSBuild.exe" DelphiCtrlTab.proj /t:CompileD28 /p:OutDir=%batPath%\build\bin\

REM Delphi Sydney
SET BDSVERSION=21.0
SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%
IF NOT EXIST "%BDS%" SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%

SET BDSCOMMONDIR=C:\Users\Public\Documents\Embarcadero\Studio\%BDSVERSION%
"%MSB%\MSBuild.exe" DelphiCtrlTab.proj /t:CompileD27 /p:OutDir=%batPath%\build\bin\

REM Delphi Rio
SET BDSVERSION=20.0
SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%
IF NOT EXIST "%BDS%" SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%

SET BDSCOMMONDIR=C:\Users\Public\Documents\Embarcadero\Studio\%BDSVERSION%
"%MSB%\MSBuild.exe" DelphiCtrlTab.proj /t:CompileD26 /p:OutDir=%batPath%\build\bin\

REM Delphi Seattle
SET BDSVERSION=17.0
SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%
IF NOT EXIST "%BDS%" SET BDS=C:\Program Files (x86)\Embarcadero\Studio\%BDSVERSION%

SET BDSCOMMONDIR=C:\Users\Public\Documents\Embarcadero\Studio\%BDSVERSION%
"%MSB%\MSBuild.exe" DelphiCtrlTab.proj /t:CompileD23 /p:OutDir=%batPath%\build\bin\


IF "%4" NEQ "NOPAUSE" pause