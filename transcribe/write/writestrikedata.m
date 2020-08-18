function [isOK, OnsetCt] = writestrikedata(xxPieceByBiXi, hb, fid)
    % Writes the supplied strike data in Lowndes format to an already opened file
	%
	% Parameters:
	%  - matrix with rows consisting of [bn, strike time in milliseconds]
	%  - Letters to be used in hand back column os lowndes file
	%  - Open output file handle
	% 
	% Actions:
	% - Checks bell numbers are contiguous integers in range 1:n for n<=16
	% - Sorts strike data by time
	% - Rounds times to integer milliseconds
	% - Writes the data to the open file
	%
	% Returns
	% - OK/Fail indicator
	% - number of blows by each bell
	
	bns = unique(xxPieceByBiXi(:,1)); % Unique sorts the items
	if bns(end) ~= length(bns) || bns(1) ~=1 || ~all(bns==round(bns)) || bns(end) > 16
	    fprintf('\n   !!! Hawkear Error. Bell numbers in strike data are not contiguous integers in range 1:n for n<=16\n\n')
		onsetCt = [];
		isOK    = 0;
	else
		OnsetCt = zeros(1, bns(end));
		bn = ['123456789OETABCD'](bns);
		xxPieceByBiXi = sortrows(xxPieceByBiXi,2);
	    timod65536 = bitand(round(xxPieceByBiXi(:,2)), 65535); % round and remove multiples of 65536 (2^16) from times
        for i=1:size(xxPieceByBiXi,1)
            bell = xxPieceByBiXi(i,1);
            stroke=hb(1+mod(OnsetCt(bell),2));
            fprintf(fid, '%s %s 0X%.4x\n', stroke, bn(bell), timod65536(i));
            OnsetCt(bell) = OnsetCt(bell)+1;
        end
	    isOK=true;
	end
end
