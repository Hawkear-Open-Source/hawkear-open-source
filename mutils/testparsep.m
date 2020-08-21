function isOK = testparsep()
    
    % Set up for calling parsep.
    % Define number of positional parameters. These will be defined in the structure
    % returned by parsep and more than this number will produce an error. If fewer
    % positional parameters are are supplied the later parameters will be set to []
    pplen=2;
    % Define valid keywords.
	%      param   type   kpstruct    def value groupname
	keywords.ts = {'str', 'suffix'   , 'TSTS' , 'train'};
	keywords.hs = {'yn',  'hopsize'  , 0      , 'train'};
    keywords.fl = {'num', 'freqlow'  , 300    , 'onset'};
	keywords.oa = {'str', 'algorithm', 'slope', 'onset'};
	keywords.by = {'yn',  'hb'       , 1      , 'onset'};
	[isOK, pp,kp, msg] = parsep(pplen,keywords, {'fn1', '-help'});

	% Test 1. Test correct call all supported types with defaults being set, case
    % insensitive keyword compare
	[isOK, pp,kp, msg] = parsep(pplen,keywords, {'fn1', '-qt:0', '-oa:n', '-ts:asd'});
    error('a')
	dpp=(disp(pp)(disp(pp)~="\n"));
	['|',dkp=(disp(kp)(disp(kp)~="\n")),'|'];
	msg
	testOK(1,1) = (isOK==1);
	testOK(1,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = [](0x0)}');
	testOK(1,3) = strcmp(dkp, '  scalar structure containing the fields:    quiet = 0    suffix = asd    hopsize = 0    freqlow =  300    algorithm = n    hb =  1    trainparams = -ts:asd -hs:n    onsetparams = -fl:300 -oa:n -by:y');
	testOK(1,4) = isempty(msg);
    %Test1OK = disp(testOK(1,:))

    % Test 2. Unwanted positional parameters, no keyword parameters
	[isOK, pp,kp,msg] = parsep(pplen,keywords, {'fn1','fn2','fn3'});
	dpp=(disp(pp)(disp(pp)~="\n"));
	['|',dkp=(disp(kp)(disp(kp)~="\n")),'|'];
	testOK(2,1) = (isOK==0);
	testOK(2,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = fn2}');
	testOK(2,3) = strcmp(dkp, '  scalar structure containing the fields:    quiet =  1    suffix = TSTS    hopsize = 0    freqlow =  300    algorithm = slope    hb =  1    trainparams = -ts:TSTS -hs:n    onsetparams = -fl:300 -oa:slope -by:y');
	testOK(2,4) = strcmp(msg,'ERROR. unwanted positional parameters');
    %Test2OK = disp(testOK(2,:))
	
    % Test 3. Invalid keyword parameter name
	[isOK, pp,kp] = parsep(pplen,keywords, {'fn1','fn2', '-qq:1'});
	dpp=(disp(pp)(disp(pp)~="\n"));
	['|',dkp=(disp(kp)(disp(kp)~="\n")),'|'];
	testOK(3,1) = (isOK==0);
	testOK(3,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = fn2}');
	testOK(3,3) = strcmp(dkp, '  scalar structure containing the fields:    quiet =  1    suffix = TSTS    hopsize = 0    freqlow =  300    algorithm = slope    hb =  1');
	testOK(3,4) = strcmp(msg,'ERROR. unwanted positional parameters');
    %Test3OK = disp(testOK(3,:))
	
    isOK=all(all(testOK));
    if isOK
        fprintf('ALL TESTS SUCCEEDED\n')
    else
        testOK
    end
end	
	%['|', '{  [1,1] = fn1  [1,2] = [](0x0)}','|']
	
