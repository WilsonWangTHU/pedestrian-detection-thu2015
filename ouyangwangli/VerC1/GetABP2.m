function [a b P2] = GetABP2(DatasetChoice, EvalAll, INRIAExt, P2, a, b, alg)
if ~EvalAll
    if DatasetChoice == 0
        a = 2;    b = - 0.3*a;
        P2 = P2 * 2;
    else
        if DatasetChoice == 4
            a = 2;
            b = - 0.3*a;
            P2 = P2 * 2;
        else
            if DatasetChoice == 2
                a = 1.5;
                P2 = P2 * 1.2;
            else
                a = 2;
            end;
            b = - 0.3*a;
        end;
    end;
else
    if DatasetChoice == 2
        if alg.c == 2
            % used for MultiFtr+Motion
            P2 = P2 * 3;
        else
        end;
    end;
    
end;

