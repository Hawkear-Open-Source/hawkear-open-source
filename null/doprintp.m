function [rc] = doprintp(parameter1, parameter2,  kpstruct)
    fprintf('\n* printp is starting\n')
    fprintf('   printp expected 2 positional parameters and received:\n     "%s"\n   and \n     "%s"\n\n', parameter1, parameter2)
	fprintf('   printp Received these keyword parameter values:\n  %s\n', disp(kpstruct))
    fprintf(' printp completed\n\n')
	rc = 0; % This gets returned to windows and can be retrieved using %ERRORLEVEL%. By convention in windows zero means OK, and non-zero means an error, with the value possibly beig=ng an error code.
end