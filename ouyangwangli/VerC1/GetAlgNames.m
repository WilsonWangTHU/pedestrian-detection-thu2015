function [Algnames resFlags ChoiceTable] = GetAlgNames(EvalAll)

if EvalAll
    Algnames{1} = 'FPDW';
    Algnames{2} = 'MultiFtr+Motion';
    Algnames{3} = 'HOG';
    Algnames{4} = 'HikSvm';
    Algnames{5} = 'Shapelet';
    Algnames{6} = 'ChnFtrs';
    Algnames{7} = 'MultiFtr+CSS';
    Algnames{8} = 'PoseInv';
    Algnames{9} = 'Pls';
    Algnames{10} = 'VJ';
    Algnames{11} = 'HogLbp';
    Algnames{12} = 'MultiFtr';
    Algnames{13} = 'LatSvm-V1';
%     Algnames{13} = 'LatSvm-V1';
    Algnames{14} = 'MultiResC';
    Algnames{15} = 'LatSvm-V2';
%     for i = 1:14
%         fprintf('%s+Our in folder  res/LatSVM-nme-%02i\n', Algnames{i}, i);
%     end
    resFlags = [1 0 1 1 0 1 0 1 0 0 1 0 0 1 0];
    ChoiceTable = [];
else
    ChoiceTable = 105;
    Algnames{1} = 'LatSVM-V2';
    resFlags = [0];
end;
