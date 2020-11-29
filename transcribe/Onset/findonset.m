function [index,rc] = findonset(v0, kpstruct, mydebug)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Finds the onset within a section of a gain vector
	% Parameters:
    % - Section in which onset is to be located
	% - kpstruct
	% - debug flag to diagnose problem blow transcriptions
    % Returns:
	% - index within section to the most likely onset
	% - Which detection stage was successful
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    index = 0; % indicates failure to find an onset
    if mydebug; fprintf(stderr,'size(v0) = [%d,%d]\n',size(v0,1),size(v0,2));end    

	% Obtain peak gain and peak gain position within section
    if mydebug;fprintf(stderr,'step 0\n');end
    [pg,pgp] = max(v0);
    if pgp <=1;
       pgp=2;
    end
    if mydebug; fprintf(stderr,'pgp = [%d]\n',pgp); end 
	
	% Onset Optimisation - attempt to optimise estimation of onset point
	if kpstruct.OnsetOptim ~= 0 
		pg2 = mean(sort(v0,'descend')(1:kpstruct.OnsetOptim));
	else
		pg2 = pg;
	end
    threshold = pg2 * kpstruct.NoiseGate;
    v1 = (v0 > threshold);
    if mydebug; fprintf(stderr,'v1 = [%s]\n',sprintf('%d ',v1)); end    

    % Get list of transitions 
    if mydebug;fprintf(stderr,'step 1\n');end
    v2 = (filter([-1 1],1,v1,1) ~= 0);
    v2(1,1) = 0;
    if mydebug; fprintf(stderr,'v2 = [%s]\n',sprintf('%d ',v2)); end    
    v3 = find(v2 ~= 0);
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end 
    if size(v3,2) == 1
        index = v3(1);
        rc = 1;
        return
    end
    
    % Remove first transition if starting high
    if mydebug;fprintf(stderr,'step 2\n');end
    if v1(1,1)
        v3 = v3(2:size(v3,2));
    end
    if size(v3,2) == 1
        index = v3(1);
        rc = 2;
        return
    end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If no more transitions, onset must be before start
    % of the section being examined. This is not good,
    % but at least gives a result. Could get doonset
    % to redo this onset with a bigger section.
    %
    % If more transitions, then if
    % finishing low remove last transition to
    % leave an odd number of transitions.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if mydebug;fprintf(stderr,'step 3\n');end
    if size(v3,2) ~= 0
        if ~v1(v3(size(v3,2)))
            v3 = v3(1:size(v3,2)-1);
        end
    else
    	index = -2; % guessing, based on a single case (StPauls) where tenor did not set
    	rc = 3;
    	return
    end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    
    
    % If now exactly one transition it must be the onset
    if mydebug;fprintf(stderr,'step 4\n');end
    if size(v3,2) == 1
        index = v3(1);
        rc=4;
        return
    end 

    % Fill narrow isolated valleys after pgp
    if mydebug; fprintf(stderr,'step 5\n'); end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    
    xxx=1;
	while xxx
        xxx=0;
        for po = 2:2:size(v3,2)-1
            if v3(po+1)-v3(po) <= 4
                if mydebug; 
                    fprintf(stderr,'po = [%s]\n',sprintf('%d ',po)); 
                end    
                v3(po) = 0;
                v3(po+1) = 0;
                v3 = v3(v3 ~= 0);
                xxx=1;
                if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end  
                break
            end
        end
    end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    
    if size(v3,2) == 1
        index = v3(1);
        rc=5;
        return
    end

    % Flatten weak peaks before pgp. Not sure this is optimal if more
	% than one weak peak before pgp
    if mydebug;fprintf(stderr,'step 6\n');end
    xxx=1;
    while xxx
       xxx=0;
       for po = 1:2:size(v3,2)-2
           if v3(po) > pgp || size(v3,2) <= 2
               break
           end
           if size(v3,2) <po+2
               fprintf(stderr,'po = %d\n',po)
               fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3))
               fprintf(stderr,'size(v3) = [%d %d]\n',size(v3,1),size(v3,2))
               fprintf(stderr,'pgp = %d\n',pgp)
           end
           % if po is small and distant from next delete it
           if v3(po+1)-v3(po) <= 3 && v3(po+2)-v3(po+1) >=2               
               v3(po) = 0;
               v3(po+1) = 0;
               v3 = v3(v3 ~= 0);
               if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end
               xxx=1;
               break
           end
       end
    end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    
    if size(v3,2) == 1 
        index = v3(1);
        rc=6;
        return
    end
    
    % Heuristic algorithm to rank the POs Lots of possible algorithms, 
	% trying "select first"
    if mydebug;fprintf(stderr,'step 7\n');end
    if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end    
    if size(v3,2)>0
        v3=v3(1:2:size(v3,2));
        if mydebug; fprintf(stderr,'v3 = [%s]\n',sprintf('%d ',v3)); end 
        fidx=find([v3,inf]>pgp);
        v4 =fidx(1)-1;
        v4=v3(max(1,v4));
        if mydebug; fprintf(stderr,'v4 = [%s]\n',sprintf('%d ',v4)); end 
        index = v4;
        rc=7;
        return
    else 
        index = max(1,pgp-10);
        rc=8;
        return
    end
end
