function [ hz ] = fi2hz (fi,NumSecs)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Converts fft frequency index  into Hz
    %
    % Copyright (C) 2008-2011 Ian McCallion (ian.mccallion.gmail.com)
    % 
    % This file is part of Hawkear
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Frequency is linear with index. So by definition
    %   F = K * (FI + C)
    % Need to find C and K
    % 
    % Since F==0 <==> FI == 1 
    %   C == -1
    % So
    %   F = K * (FI - 1)
    %   K = F/(FI-1)        (***)
    %
    % Let FH = highest freq that a signal with a given sample
    % rate can contain. Since a full wave needs 2 samples 
    %
    %   FH = SamplesPerSec/2 %Hz
    %
    % There are as many indices as samples in the signal being fft'd but
    % Second half is mirror of first half so highest frequency is in the
    % middle sample. Let FHI = frequency index of highest frequency.
    %
    %   FIH = nSamples/2
    %
    % Substituting in (***)
    % K = FH/(FIH-1) = (SamplesPerSec/2) / (nSamples/2) == SamplePerSec/nSamples 
    %    == 1/(nSamples/SamplesPerSec) == 1/NumSecs
    %
    % Hence:
    %                 F = (FI-1)/NumSecs
    %                 FI = F*NumSecs+1
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    hz = (fi-1)/NumSecs;
end
