@echo off
rem Called with no parameters hoscall sets up the environment ready for issuing HOA cammands
rem from the current window: e.g.
rem    hoscall
rem    transcribe fqfnAudio fqfnTrain fqfnTranscription -fl:500
rem    analyse fqfnAudio fqfnTranscription fqdnAnalysis
rem    website fqdnWebsite
rem
rem Called with parameters hoscall sets up the environment and treats the parameters as a hos command.
rem Used like this the fully qualified filename of hoscall can be supplied and the environment hoscall sets up
rem will be dismantled before return. This can be used from a windows command line but can also be called from
rem any code capable of issuing a windows start command. E.g.:
rem     c:\HOS\hoscall transcribe fqfnAudio fqfnTrain fqfnTranscription -fl:500
rem 
rem The HOS workflow director can be written in any language and use this to obtain all hos functions, except
rem perhaps record.

rem Call a HOS component. Will set up the required environment and call the named component with the supplied parameters.
rem will restore all environment variables
rem example
rem   hoscall transcribe fnAudio fnTrain fnTranscription -fl:500

if NOT "%*" == "" (
    setlocal
) else (
	echo Setting up window for calling HawkEar Open Source APIs
)
cd %~dp0

rem developers should set edit this file and set HOSWORK where they want it AND CREATE THE DIRECTORY
    set HOSWORK=%USERPROFILE%\documents\backed\hoswork

rem Access to octave. Developers should edit this to be the version of Octave they have installed
    set hoso=C:\Octave\Octave-5.2.0
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
rem calls each component's myvars.cmd
    for /d %%c in (*) do (
        if exist %%c\myvars.cmd (
			echo. >nul
			echo *** Initialising component "%%c" >nul
            call %%c\myvars.cmd >nul
        ) 
    )
	echo. >nul

rem call the HOS command if requested
    if  not .%1 == . (
        call %*
    )

if NOT "%*" == "" (
    endlocal
)
:fexit