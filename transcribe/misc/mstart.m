function [fid ] = mstart(mstring)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    mstart.m - launch another copy of Octave and run mstring in it
    %    Caller must prepend the necessary addpath command to the
	%    supplied string.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (isoctave())
       fid=cmdstart(strcat('octave-cli -q --no-window-system --eval "', mstring, '"'));
   else
       mstringexit=strcat(mstring,';exit;');
       cmd=strcat('matlab -nosplash -nodesktop -minimize -r "', mstringexit, '"');
       fprintf('%s', cmd);
       fid=cmdstart(cmd);
   end
end
