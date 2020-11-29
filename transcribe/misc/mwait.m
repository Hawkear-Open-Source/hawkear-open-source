% MWAIT wait for a launched process to end
function [result] = mwait(fid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of HawkEar.
%
% Copyright (C) 2008-2012 Ian McCallion (ian.mccallion@gmail.com)
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result='';
if (isoctave())
    
    try
        s = fgets(fid);
    catch
        result = 'pipe not open';
        return
    end
    
    while (strcmp(class(s),'char'))
        if strcmp(class(s),'char')
            fprintf(s);
        end
        s = fgets(fid);
    end
    
    rc=pclose(fid);
else
    rc = fid.waitFor();
end

if (rc~=0)
    result='error running external process';
end

end