function [retval] = ratio2db (input1)
% RATIO2DB Converts a signal amplitude ratio to decibels
%
% The convention adopted is that an amplitude of 1 == 0dB

retval=20*log10(input1);
end
