@echo off
rem prepare for a component to use Octave

rem EDIT THIS TO BE THE LOCATION OF THE VERSION OF OCTAVE TO BE USED
    set hoso=C:\Octave\Octave-5.2.0

rem find the appropriate Octave binary 
    set HOSOCTAVE=%hoso%\bin\octave.bat        
    if exist %HOSOCTAVE% goto okf2		
    set HOSOCTAVE=%hoso%\mingw64\bin\octave.bat
    if exist %HOSOCTAVE% goto okf2		
    set HOSOCTAVE=%hoso%\mingw32\bin\octave.bat
    if exist %HOSOCTAVE% goto okf2
    echo .***************************************************************
    echo .       *** Octave could not be located ***
    echo .       *** at the specified location   ***
    echo .***************************************************************
    goto fexit
    :okf2
	set hoso=
