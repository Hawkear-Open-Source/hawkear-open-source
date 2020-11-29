function [mt]=octave_twister_seed(seed)
    N=624;   
    mt=uint32(zeros(N,1));
    
    % MATLAB 7 and above round to nearest ....
    useed = fix(seed);
    
    MASK=uint64(intmax('uint32'));
    % The modern approach is to see this directly.....
    mt=twister_seed(uint32(19650218));
    
    i=2;
    for k=1:N  
        temp = bitxor(uint64(mt(i)), uint64( bitxor(mt(i-1), bitshift(mt(i-1),-30)))* uint64(1664525))+ useed; 
        mt(i) = uint32(bitand(temp, MASK));
        i=i+1;
        if (i>N)
          mt(1)=mt(N);
          i=2;
        end
    end
    
    for k=1:N-1
        % Annoying MATLAB indexing correction
        temp = bitxor(uint64(mt(i)) ,  uint64(bitxor(mt(i-1) , bitshift(mt(i-1),-30))) * uint64(1566083941)) - (i-1); 
        mt(i) = uint32(bitand(temp, MASK));
        i=i+1;
        if (i>N)
          mt(1)=mt(N);
          i=2;
        end

    end

    mt(1) = 2147483648; % 0x80000000 MSB is 1; assuring non-zero initial array 
    mt(625)=N; %the pointer
end