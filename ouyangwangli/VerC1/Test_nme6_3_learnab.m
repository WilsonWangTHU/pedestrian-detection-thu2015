function Test_nme6_3_learnab(DatasetChoice, Tchoice, dstbasepath, c, Frames, BBname, bbshowset_all, LatSVM_Model)
Choice = 0;
NoParts = 1;
ScoreAdd = 0;

load('../Params/INRIA_ovlpPos_MOG1_DR2.mat');
load('../Params/INRIA_ovlpPos3.mat');
for i = 1:length(center)
    Centers((i-1)*3+1:i*3, :) = center{i};
    Vars((i-1)*3+1:i*3, :) = variance{i};
end;
load(BBname, 'bbshowset_all');
fnum = length(bbshowset_all);
switch DatasetChoice % 1: ETHZ;  2: tudbrussels 4: Caltech-Test
    case 1
        load('../Params/ETHFileNames');
    case 2
        load('../Params/tudbrussels');
    case 4
        load('../Params/Caltec_TestFilename');
end;
scores = [];
for i = 1:100 %for each frame
    bbshow = bbshowset_all{i};
    if ~isempty(bbshow)
        scores = [scores; bbshow(:, end)];
    end;
end;
a = max(6/scores); 
b = - 0.6*a;
save('Param_ab', 'a', 'b');

