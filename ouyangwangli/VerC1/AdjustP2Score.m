function [P2] = AdjustP2Score(DatasetChoice, INRIAExt, EvalAll, Context_Ped2_3)
if EvalAll
    P2 = Context_Ped2_3 * 0.25;
else
    if DatasetChoice == 2 || DatasetChoice == 4
        P2 = Context_Ped2_3 * 0.15;%0.18
    else
        P2 = Context_Ped2_3 * 0.25;%0.18
    end;
end;
