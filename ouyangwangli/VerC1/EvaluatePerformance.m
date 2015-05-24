function [] = EvaluatePerformance(DatasetChoice, LatSVM_Model, Frames, ChoiceTable)
    if LatSVM_Model
        switch DatasetChoice %0: caltech train;  1: ETHZ;  2: tudbrussels 3: Occ
            case 1
                dbEvalETH_new(Frames, 4500, length(ChoiceTable));
                %         dbEvalETH_new(Frames, 4100+c, length(ChoiceTable));
            case 2
                dbEvalTUD_new(Frames, 4500, length(ChoiceTable));
                %             dbEvalTUD_new(Frames, 4500, length(ChoiceTable));
            case 4
                %             dbEval_new_test(Frames, 4511, true(4025, 1), length(ChoiceTable));
                dbEval_new_test(Frames, 4500, true(4025, 1), length(ChoiceTable));
        end;
    end;
