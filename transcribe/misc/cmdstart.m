function [fid ] = cmdstart(mstring)
%CMDSTART launch mstring as external command and return a handler for mwait

   if (isoctave())
        fid=popen(mstring, 'r');   
   else
       runtime = java.lang.Runtime.getRuntime();   
       fid= runtime.exec(mstring);
   end
   
end

	
