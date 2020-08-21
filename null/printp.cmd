@rem prepare parameters for passing to Octave
@setlocal
@set P=.%*
@set P=%P:{=%
@set P=%P:"={%
@set P=%P:}=%
@set P=%P:'=}%

@rem Put octave into debug mode prior to launching (rem the to avoid this)
@rem @set HOSTRIGGERDEBUGMODE=keyboard

@rem call octave to do the job
@call "%hosoctave%" -q --eval "addpath('null');addpath('mutils'); %HOSTRIGGERDEBUGMODE%; rc=printp('%P%');exit(rc)"
