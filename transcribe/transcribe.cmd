@echo off
rem prepare parameters for passing to Octave
@set P=.%*
@set P=%P:{=%
@set P=%P:"={%
@set P=%P:}=%
@set P=%P:'=}%
rem call octave to do the job

if 1 == 0 (
   call "%hosoctave%" -q --eval "addpath('transcribe');addpath('mutils'); keyboard; transcribe('%P%')"
) else (
   call "%hosoctave%" -q --eval "addpath('transcribe');addpath('mutils'); rc=transcribe('%P%');exit(rc)"
)
:exit
