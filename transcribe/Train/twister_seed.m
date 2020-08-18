function ret = twister_seed(SEED)

    ret = uint32(zeros(625,1));
    ret(1) = SEED;
    for N = 1:623
        %initialize_generator
        % bit-xor (right shift by 30 bits)
        uint64(1812433253)*uint64(bitxor(ret(N),bitshift(ret(N),-30)))+N;  % has to be uint64, otherwise in 4th iteration hit maximum of uint32!
        ret(N+1) = uint32(bitand(ans,uint64(intmax('uint32')))); % untempered numbers
    end
    ret(end)=1;
end