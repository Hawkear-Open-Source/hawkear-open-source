function [ret] = dofasttrainloop(inputdir, SampleRate, WinSizeSecs, HopSizeSecs, outputfn, bells)
	% DOFASTTRAINLOOP invoke dofasttrainloop2 and save results to outputfn
	% dofasttrainloop2 can be called in process to put train data directly into allbasis
	[somebasis, tpdata] = dofasttrainloop2(inputdir, SampleRate, WinSizeSecs, HopSizeSecs, bells);
	save('-mat', outputfn, 'somebasis', 'tpdata');
	ret=1;
end
