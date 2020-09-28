@echo off
rem Two methods of using hoscall:
rem
rem 1. Call with no parameters. Sets up the HOS environment ready for issuing HOS API calls
rem    from the current window: e.g.
rem        hoscall
rem        transcribe fqfnAudio fqfnTrain fqfnTranscription -fl:500
rem        analyse fqfnAudio fqfnTranscription fqdnAnalysis
rem        website fqdnWebsite
rem
rem 2. Call with parameters. Sets up the HOS environment and treats the parameters as a HOS API call.
rem    Used like this the fully qualified filename of hoscall can be supplied and the environment
rem    hoscall sets up will be dismantled before return. This can be used from a windows command
rem    line but can also be called from any code capable of issuing a windows start command. E.g.:
rem        c:\HOS\hoscall transcribe fqfnAudio fqfnTrain fqfnTranscription -fl:500
rem    The HOS workflow director and any other HOS component can use this to call hos APIs

if NOT "%*" == "" (
    setlocal
) else (
	echo Setting up window for calling HawkEar Open Source APIs
)
cd %~dp0
	
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