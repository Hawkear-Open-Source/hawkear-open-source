fqdntest = fullfile(getenv('APPDATA'), 'HOS','testdata');
fqfnLowndes = fullfile(fqdntest, 'Thunston.20200202-0000.s8t8.1.txt');
[a,b]=unlink (fqfnLowndes)
transcribe(fullfile(fqdntest, 'Thunston.20200202-0000.s8t8.1.wav'), ...
           fullfile(fqdntest, 'Thunston.train.bin'), ...
		   fullfile(fqdntest,'Thunston.20200202-0000.s8t8.1.txt'), ...
		  % '-fl:320',...
		   '-qt:2');
		   if exist(fqfnLowndes,'file')
		       disp('Test successful')
    		   system (['dir ', fqdntest, '\Thunston.20200202-0000.s8t8.1.txt'])
		   else
		       disp('Test failed')
		   end
% Now check the result		   