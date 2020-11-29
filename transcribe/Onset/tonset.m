% note that this is nearly done. just need to finish the debug capabilities and
% integrate it into a new version of hawkear

%% Copyright (C) 2013 Ian
%% Created: 2013-03-30

function [ index ] = tonset (bell)
    %                 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6
    mixtureB(1,:) =  [0 0 0 0 1 1 1 1 1 1 1 1 1 2 1 1 1 1 0 0 0 0 0 0]; 
    %                  5 19
    mixtureB(2,:) =  [1 0 0 0 1 1 1 0 0 0 0 1 1 2 1 1 1 1 0 0 0 0 0 0]; 
    %                 2 5 11 12 19
    mixtureB(3,:) =  [1 1 0 0 0 1 1 0 1 0 0 1 1 2 1 1 1 0 0 0 0 0 1 1]; 
    %                  3 6 8 9 10 12 18 23
    mixtureB(4,:) =  [1 1 0 0 0 1 1 0 1 0 0 1 1 2 1 1 1 0 1 0 0 0 1 1]; 
    %                  3 6 8 9 10 12 18 19 20 23
    mixtureB(5,:) =  [1 1 0 0 0 1 1 1 1 0 0 1 1 2 1 1 1 0 1 0 0 0 1 1]; 
    %                  3 6 8 9 10 12 18 19 20 23
    mixtureB(6,:) =  [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; 
    mixtureB(7,:) =  [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; 
    mixtureB(8,:) =  [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0]; 
    mixtureB(9,:) =  [1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1]; 
    i = 13 ;
    MaxBack = i-1;
    MaxForward = size(mixtureB,2)-i;
    index= FindOnset(mixtureB(bell,:),.3,1);
end

