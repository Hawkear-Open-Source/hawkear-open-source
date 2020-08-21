@rem prepare parameters for passing to Octave
@setlocal
@set P=.%*
@set P=%P:{=%
@set P=%P:"={%
@set P=%P:}=%
@set P=%P:'=}%

@rem Put octave into debug mode prior to launching (rem out to avoid this)
rem @set HOSTRIGGERDEBUGMODE=keyboard

@rem call octave to do the job
@call "%hosoctave%" -q --eval "addpath('transcribe');addpath('mutils'); %HOSTRIGGERDEBUGMODE%; rc=train('%P%');exit(rc)"
