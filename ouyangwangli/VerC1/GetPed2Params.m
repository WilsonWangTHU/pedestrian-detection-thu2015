function [Ped2ScoreAdd T_Ped2]  = GetPed2Params(DatasetChoice, LatSVM_Model, INRIAExt)
if DatasetChoice ==4
    Ped2ScoreAdd = 0.2;
    T_Ped2 = -0.2; 
end;
if DatasetChoice ==0
        Ped2ScoreAdd = 0.2;
        T_Ped2 = -0.2; 
end;
if DatasetChoice ==1
    Ped2ScoreAdd = 0.0;
    T_Ped2 = -0.03; 
end;
if DatasetChoice ==2
    T_Ped2 = -0.03;
        Ped2ScoreAdd = 0.2;
%     T_Ped2 = -0.0298;
%     Ped2ScoreAdd = 0;
end;
