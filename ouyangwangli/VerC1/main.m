global EvalAll; EvalAll = true;  %true; 
% True: evaluate all approaches except LatSVM-V2
% False: evaluate only LatSVM-V2, average miss rate should be 41%, 63% and 58% for ETH, TUD and Caltech respectively
% We admit that we have tuned the parameters for LatSVM-V2. But our
% approach still improve LatSVM-V2 with large margin even if the parameters
% are fixed.

OneAlg = false;

fclose all;
global T_Ped2;
global Ped2ScoreAdd; 
Ped2Choice = 6;
addpath('../eval');
if ~exist('parthadd', 'var')
    addpath('../eval');
    parthadd = 1;
end;


Frames = 0;
global Choice;
Choice = 205;
global INRIAExt;  INRIAExt = false; 

LatSVM_Model = 1; % 1: DPM parts model
Tchoice = 1; %0: see the single pedestrian result  1: Single aiddd by multiple;


ReloadTrainData_ped2 = 0;
ReLoadPos_ped2 = 0;
ReLoadNeg_ped2 = 0;


[Algnames resFlags ChoiceTable] = GetAlgNames(EvalAll);


for DatasetChoice = [1 2 4]  % 1: ETHZ;  2: tudbrussels  4: Caltech Test    
    if EvalAll
        if OneAlg == 1
            NumLoop = 1;
        else
            if DatasetChoice == 4
                NumLoop = 14;
            else
                NumLoop = 13;
            end;
        end;
    else
        NumLoop = 1;
    end;
    for c = [1:NumLoop] 
%     for c = [NumLoop:-1:1] 
        if EvalAll
            if OneAlg
                ChoiceTable = 1;
            else
                if DatasetChoice == 4
                    ChoiceTable = [105 1:10+3];
                else
                    ChoiceTable = [105 1:9+3];
                end;
            end
        else
            ChoiceTable = zeros(NumLoop, 1);
            Algnames{1} = 'LatSVM-V2';
            resFlags = zeros(NumLoop, 1);
        end;
        alg.DatasetChoice = DatasetChoice;
        resFlag = resFlags(c);
        alg.c = c;
        if EvalAll
            if c == 14
                alg.resize = {resFlag 96/100 32/41 0};
            else
                if c == 11
                    alg.resize = {resFlag 96/96 32/48 0};
                else
                    if c == 1 || c==6
                        alg.resize = {resFlag 96/96 32/48 0};
                    else
                        alg.resize = {resFlag 100/128 41/64 0};
                    end;
                end;
            end;
        end;
        Choice = ChoiceTable(1); %This influences the function GetBBContext
        Algname = Algnames{c};
        [Ped2ScoreAdd T_Ped2] = GetPed2Params(DatasetChoice, LatSVM_Model, INRIAExt);
        if LatSVM_Model
            [dstbasepath BBname BBname_Ped2] = GetBBName(DatasetChoice, Ped2Choice, EvalAll, INRIAExt, c, Algname);
       end;
        ps = [1 1];
        if ~exist('BBname_Ped2_old', 'var') || ~strcmp(BBname_Ped2_old, BBname_Ped2)
            load(BBname_Ped2, 'bbshowset_all');
        end;
        fprintf('Using  %s as single pedestrian detector\n', Algname);
        fprintf('New results are in %s\n', dstbasepath);
        Test_nme6_3_learnab(DatasetChoice, Tchoice, dstbasepath, c, Frames, BBname, bbshowset_all,  LatSVM_Model);        
        Test_nme(alg, ps, DatasetChoice, Tchoice, dstbasepath, c, Frames, BBname, bbshowset_all,  LatSVM_Model);
        BBname_Ped2_old = BBname_Ped2;
    end
    EvaluatePerformance(DatasetChoice, LatSVM_Model, Frames, ChoiceTable);
    Train = 0;
end;