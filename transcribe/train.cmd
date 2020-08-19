@echo off
rem prepare parameters for passing to Octave
@set P=.%*
@set P=%P:{=%
@set P=%P:"={%
@set P=%P:}=%
@set P=%P:'=}%
rem call octave to do the job

if 1 == 1 (
   call "%hosoctave%" -q --eval "addpath('transcribe/train');addpath('mutils'); keyboard; train('%P%')"
) else (
   call "%hosoctave%" -q --eval "addpath('transcribe/train');addpath('mutils'); rc=train('%P%');exit(rc)"
)
:exit
