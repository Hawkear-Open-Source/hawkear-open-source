function [CHR] = GetChangeRateHz (mixtureA, HopSizeSecs, varargin)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GetChangeRate
    %
    %    Calculate the speed of ringing based on the output
    %    from the gain phase.
    %
    %    Return the speed of ringing in changes/second
    %
    % Copyright (C) 2008-2011 Ian McCallion (ian.mccallion.gmail.com)
    % 
    % This file is part of Hawkear
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    verbose = length(varargin)>0;
    SamplesPerSec = 1/HopSizeSecs;    
	nSamples = size(mixtureA,1);
	nBells = size(mixtureA,2);
    NumSecs = nSamples/SamplesPerSec;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Merge the per-bell signals and fft into frequency
	% domain. Truncate second half as it is mirror of
	% first
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    ff = fft(sum(mixtureA,2));
    ff=ff(1:round(size(ff,1)/2));

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% spectrum contains peaks corresponding to the 
	% change rate and the blow rate. We use the blow rate
	% as this has a better chance of being accurate for
	% short pieces of ringing. Hence apply a highpass
	% filter (implemented by zeroing out lower elements
	% of ff). Cutoff frequency is chosen to be high
	% enough to eliminate frequencies corresponding to 
	% the change rate and 5 harmonics which are typically
    % present. Slowest blow rate would be for 6-bell 
    % ringing at a 4h00 peal speed,  
    % (5040*6.5)/(4*3600) = 2.275Hz
    % fastest change rate would be for a peal in 2 hours
    % 5040/7200 = .7Hz
    % 5th harmonic of change rate is 4.2Hz, which is 
    % greater than 2.275Hz. so need to factor in the
    % number of bells. OR find the change rate first and
    % do a rough calculation of blow rate and 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    maxindividualbellrate = 5040/7200; % blows per second
    fiCutoff = hz2fi(maxindividualbellrate*6,NumSecs);
    ff(1:fiCutoff) = 0;
    ff = abs(ff);
    [maxff,BRI] = max(ff); % should correspond to blow rate
    clear maxff
	BR  = fi2hz(BRI,NumSecs);
    CHR = BR/(nBells+.5);
	
	if verbose
        fprintf('Debug data\n');
        fprintf('    Recording Length: %s\n',gst(NumSecs));
        [m,s] = tdiv(round((1/CHR)*5040),60);
        [h,m] = tdiv(m,60);
        fprintf('    PealSpeed: %s\n',gst(round((1/CHR)*5040)))
        fprintf('    288chSpeed: %s\n',gst(round((1/CHR)*288)))
        size(ff)
        plot(ff)
	end
end


function [dur] = gst(secs)
    [m,s] = tdiv(secs,60);
    [h,m] = tdiv(m,60);
    dur = sprintf('%d:%d:%d',h,m,s);
end

function [h,m] = tdiv(p,q)
   h=floor(p/q);
   m=p-h*q;
end

