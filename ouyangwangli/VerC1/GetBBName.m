function [dstbasepath BBname BBname_Ped2]  = GetBBName(DatasetChoice, Ped2Choice, EvalAll, INRIAExt, c, Algname)
% simply getting the name of the data base the dstbasepath is the result
% output dir

switch DatasetChoice % 0: caltech train;  1: ETHZ;  2: tudbrussels 3: Occ
    case 1
        dstbasepath = sprintf('../eval/data-ETH/res/LatSVM-nme-%02i/', c);
        if EvalAll 
            BBname = ['../Params/' Algname 'allBoxesETH.mat'];
        else
            BBname = '../Params/LatSVM_allBoxesETH_p.mat';
        end;
        BBname_Ped2 = '../Params/LatSVM-2Ped9C_3P_allBoxesETH_Linux_INRIA_SC1_DR2.mat';
    case 2
        dstbasepath = sprintf('../eval/data-TudBrussels/res/LatSVM-nme-%02i/', c);
        if EvalAll 
            BBname = ['../Params/' Algname 'allBoxesTUD.mat'];
        else
            BBname = '../Params/LatSVM_allBoxesTUD.mat';
        end;
        BBname_Ped2 = '../Params/LatSVM-2Ped9C_3P_allBoxesTUD_Linux_INRIA_SC1_DR2.mat';
    case 4
        dstbasepath = sprintf('../eval/data-usa/res/LatSVM-nme-%02i/', c);
        if EvalAll 
            BBname = ['../Params/' Algname 'allBoxesCaltechTest.mat'];
        else
            BBname = '../Params/LatSVM_allBoxesCaltechTest_p.mat';
        end;
        BBname_Ped2 = '../Params/LatSVM-2Ped9C_3P_allBoxesCaltechTest_Linux_INRIA_SC1_DR2.mat';
end;
% The single pedestrian detection results are obtained from http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/
% The single pedestrian detection results for LatSVM-V2 are obtained by us.
