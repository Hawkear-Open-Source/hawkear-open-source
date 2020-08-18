function isOK = testparsep()
    
    % Set up for calling parsep.
    % Define number of positional parameters. These will be defined in the structure
    % returned by parsep and more than this number will produce an error. If fewer
    % positional parameters are are supplied the later parameters will be set to []
    pplen=2;
    % Define valid keywords. Fieldnames of the keywords structure are valid parameters
    % on commandline
    keywords.qt={'num', 'na', 2     };
    keywords.fl={'num', 'nb', 300   };
	keywords.xx={'str', 'sa', 'AAAA'};
	keywords.yy={'str', 'sb', 'BBBB'};
	keywords.by={'yn',  'by', 1     };
	keywords.bn={'yn',  'bn', 0     };
	keywords.bd={'yn',  'bd', 0     };

	% Test 1. Test correct call all supported types with defaults being set, case
    % insensitive keyword compare
	[isOK, pp,kp, msg] = parsep(pplen,keywords, {'fn1', '-qt:0', '-Fl:850.1', '-by:n', '-bn:y'});
	dpp=(disp(pp)(disp(pp)~="\n"));
	dkp=(disp(kp)(disp(kp)~="\n"));
	testOK(1,1) = (isOK==1);
	testOK(1,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = [](0x0)}');
	testOK(1,3) = strcmp(dkp, '  scalar structure containing the fields:    na = 0    nb =  850.10    sa = AAAA    sb = BBBB    by = 0    bn = 1    bd = 0');
	testOK(1,4) = isempty(msg);
    %Test1OK = disp(testOK(1,:))

    % Test 2. Unwanted positional parameters, no keyword parameters
	[isOK, pp,kp,msg] = parsep(pplen,keywords, {'fn1','fn2','fn3'});
	dpp=(disp(pp)(disp(pp)~="\n"));
	dkp=(disp(kp)(disp(kp)~="\n"));
	testOK(2,1) = (isOK==0);
	testOK(2,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = fn2}');
	testOK(2,3) = strcmp(dkp, '  scalar structure containing the fields:    na =  2    nb =  300    sa = AAAA    sb = BBBB    by =  1    bn = 0    bd = 0');
	testOK(2,4) = strcmp(msg,'ERROR. unwanted positional parameters');
    %Test2OK = disp(testOK(2,:))
	
    % Test 3. Invalid keyword parameter name
	[isOK, pp,kp] = parsep(pplen,keywords, {'fn1','fn2', '-qq:1'});
	dpp=(disp(pp)(disp(pp)~="\n"));
	dkp=(disp(kp)(disp(kp)~="\n"));
	testOK(3,1) = (isOK==0);
	testOK(3,2) = strcmp(dpp, '{  [1,1] = fn1  [1,2] = fn2}');
	testOK(3,3) = strcmp(dkp, '  scalar structure containing the fields:    na =  2    nb =  300    sa = AAAA    sb = BBBB    by =  1    bn = 0    bd = 0');
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
