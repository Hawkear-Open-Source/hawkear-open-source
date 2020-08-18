To try out the alpha release:

1. Copy the data from HOS.zip in the shared google drive to
     %APPDATA%\HOS
   This contains test data and the cpptranscribe executables.
   
2. open a windows commandline

3. execute hosgo.cmd in your window. This will change the current directory and initialise the HOS environment (basically a few path statements)

4. testtrain

5. testtranscribe

At present there are a few bodges such that you will not be able to transcribe any other files. I'll fix them and document the APIs more fully.

Note that there is a latent bug in strikeanalyser that is exposed by HOS. Current code lines 71-76:

    % 1.2 Obtain time offset relative to the audio file if applicable, or use 0
    timeoffset = 0;
    firstBlowIdx = find(~cellfun(@isempty,strfind(comments,"FirstBlowMs")));
    if (~isempty(firstBlowIdx))
        timeoffset = str2num(substr(comments{13},17));
    end
	
Fixed code:

    % 1.2 Obtain time offset relative to the audio file if applicable, or use 0
    timeoffset = 0;
    firstBlowIdx = find(~cellfun(@isempty,strfind(comments,"FirstBlowMs")));
    if (~isempty(firstBlowIdx))
        timeoffset = str2num(substr(comments{firstBlowIdx},17));
    end

I will change legacy HawkEar, but if you have a copy you are working on you'll need to change it yourself in order to analyse HOS transcriptions

