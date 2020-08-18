function [X] = spectrogram(x,window,noverlap,nfft);
	% SPECTROGRAM Computes a quantized spectrogram of input signal    
	%
	% This file is part of HawkEar.
	%
	% Copyright (C) 2008-2012 Ian McCallion (ian.mccallion.gmail.com)
	% All rights reserved. 
	
    nhop = nfft-noverlap;
    nframes = floor((length(x)-noverlap)/nhop);
    X = zeros(nfft,nframes);
    xoff = 0;
    for m=1:nframes
        X(:,m) = fft(x(xoff+1:xoff+nfft) .* window);
        xoff = xoff + nhop;   % advance in-pointer by hop size
    end
end
