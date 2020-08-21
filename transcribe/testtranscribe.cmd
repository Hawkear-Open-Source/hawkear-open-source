setlocal
set fqdntest=%APPDATA%\HOS\testdata
set fqfnLowndes=%fqdntest%\Thunston.20200202-0000.s8t8.1.txt
del %fqfnLowndes%
transcribe %fqdntest%\Thunston.20200202-0000.s8t8.1.wav  %fqdntest%\Thunston.train.bin %fqdntest%\Thunston.20200202-0000.s8t8.1.txt -qt:0
rem if exist(fqfnLowndes,'file')
rem     disp('Test successful')
rem   system (['dir ', fqdntest, '\Thunston.20200202-0000.s8t8.1.txt'])
rem else
rem     disp('Test failed')
rem end
