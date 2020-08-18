@echo off
rem prepare parameters for passing to Octave
@set P=.%*
@set P=%P:{=%
@set P=%P:"={%
@set P=%P:}=%
@set P=%P:'=}%
rem call octave to do the job
rem call "%hosoctave%" -q --eval "addpath('null');addpath('mutils'); keyboard; printp('%P%')"
call "%hosoctave%" -q --eval "addpath('null');addpath('mutils'); rc=printp('%P%');exit(rc)"
rem call "%hosoctave%" -q --eval "addpath('null');addpath('mutils'); keyboard; rc=printp('%P%');exit(rc)"
:exit
