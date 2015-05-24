function [] = Test_nme(alg, ps, DatasetChoice, Tchoice, dstbasepath, c, Frames, BBname, bbshowset_all, LatSVM_Model)
Choice = 0;
NoParts = 1;
ScoreAdd = 0;
global Ped2ScoreAdd;
global EvalAll;
global UsePedParts;
Ovlap_T = 0.01;
global T_Ped2;
load('../Params/INRIA_ovlpPos_MOG1_DR2.mat');
load('../Params/INRIA_ovlpPos3.mat');
for i = 1:length(center)
    Centers((i-1)*3+1:i*3, :) = center{i};
    Vars((i-1)*3+1:i*3, :) = variance{i};
end;
bbset_ped2_all = bbshowset_all;
load(BBname, 'bbshowset_all');
name = ['Var_Ped2_MOG1_DR2_2'];
load(['../Params/' name], 'Var1', 'Var2');

fnum = length(bbshowset_all);

if Frames > 0
    fnum = min(fnum, Frames);
end;
Ped2Num = 0;
Ped1Num = 0;

switch DatasetChoice %  1: ETHZ;  2: tudbrussels 4: CaltechTest
    case 1
        load('../Params/ETHFileNames');
    case 2
        load('../Params/tudbrussels');
    case 4
        load('../Params/Caltec_TestFilename');
end;
InitT = 1;
CandNum = 500;
load('Param_ab');
global INRIAExt;
for i = 1:fnum %for each frame
    ys = [];
    hs = [];
    bbshow = bbshowset_all{i};
    if ~isempty(bbshow)
        if LatSVM_Model || DatasetChoice == 4
            if (DatasetChoice ~= 2 && DatasetChoice ~= 0) ||EvalAll || INRIAExt
                bbshow = bbshow';
            end;
        end;
        bbshow = bbshow([1:4 end], :)';
        if EvalAll
            if(alg.resize{1}), bbshow=bbApply('resize',bbshow,alg.resize{2:4}); end;
        end;
        
        if InitT
            InitT = 0;
            score = bbshow(:, end);
            score = sort(score, 'descend');
            ThrNew = GetThreshold(LatSVM_Model, EvalAll);
            fprintf('ThrNew: %f\n', ThrNew);
            bbshow(bbshow(:, end)<ThrNew, :) = [];
            fprintf('Num of Cands: %f\n', size(bbshow,1));
            if size(bbshow,1) > CandNum %220 is good
                ThrNew = score(CandNum);
                fprintf('ThrNew: %f\n', ThrNew);
                bbshow(bbshow(:, end)<ThrNew, :) = [];
                fprintf('Num of Cands: %f\n', size(bbshow,1));
            end;
            Thr = min(bbshow(:, end));
        end;
        bbshow(bbshow(:, end)<ThrNew, :) = [];
        N = size(bbshow, 1);
        Keep = false(N);
        Ped1Num = Ped1Num + size(bbshow, 1);
        if Tchoice == 0
            Score = bbshow(:, end);
        else
            bbshow(:, end) = bbshow(:, end) + ScoreAdd;
            y = [bbshow(:, 2) ];
            h = [bbshow(:, 4) ];
            y = y - h;
            ys = y;
            hs = h;
            hs1 = h;
            ys1 = y;
            
            bbPed2 = bbset_ped2_all{i}(1:end-1, :);
            bbPed2(:, bbPed2(end, :) < T_Ped2) = [];
            bbPed2(end, :) = bbPed2(end, :) + Ped2ScoreAdd;
            bbPed2 = bbPed2';
            bbPed2_1 = [];
            if ~isempty(bbPed2)
                if UsePedParts
                    pick_Ped2 = nms_pick(bbPed2(:, [1:4 end]), 0.5);
                    bbPed2 = bbPed2(pick_Ped2(:, 1:end-1), :);
                    bbPed2(:, 3:4) = bbPed2(:, 3:4) + bbPed2(:, 1:2);
                else
                    %Two Ped
                    P3 = bbPed2(:, [1:4 end]);
                end;
            end;
            
            if ~isempty(bbPed2)
                Ped2Score = 0;
                bbPed2Mixture = int8(bbPed2(:, 15)*2);
                Ped2Num = Ped2Num + size(bbPed2, 1);
                Context_Ped2_3 = zeros(size(bbshow, 1), 1);
                bbPed2Score2 = zeros(size(bbshow, 1), 1);
                
                bbPed2_Mix = bbPed2(:, :);
                P21 = bbPed2_Mix(:, 4+1:4+5);
                P22 = bbPed2_Mix(:, 4+5+1:4+5+5);
                y = [P21(:, 2); P22(:, 2)];
                h = [P21(:, 4); P22(:, 4)];
                h = h - y;
                y = y - h;
                ys = [ys; y];
                hs = [hs; h];
                for MixtureChoice = 1:9
                    MixtureFlag = (bbPed2Mixture == MixtureChoice);
                    bbPed2_Mix = bbPed2(MixtureFlag, :);
                    P21 = bbPed2_Mix(:, 4+1:4+5);
                    P22 = bbPed2_Mix(:, 4+5+1:4+5+5);
                    pick_P2 = nms_pick(P21(:, [1:4 end]), 0.995);
                    P21 = P21(pick_P2, :);
                    [Choice1 Context1 Overlap1] = TestOverlap_Ped2(bbshow(:, [1:4 end]), P21, Var1(:, MixtureChoice), alg);
                    [Overlap1_C Overlap1_I] = max(Overlap1, [], 1);
                    P22 = P22(pick_P2, :);
                    [Choice2 Context2 Overlap2] = TestOverlap_Ped2(bbshow(:, [1:4 end]), P22, Var2(:, MixtureChoice), alg);
                    bbPed2Score = bbPed2_Mix(:, end);
                    if DatasetChoice == 4 && ~EvalAll
                        bbPed2Score = bbPed2Score(pick_P2, :)*4;
                        bbPed2Score = bbPed2Score - 0.5;
                    else
                            bbPed2Score = bbPed2Score(pick_P2, :)*2;
                    end;
                    bbPed2Score = 1./(1+exp(-bbPed2Score));
                    if ~isempty(P21)
                        Conflict = (Choice1 == Choice2);
                        bbPed2Score3 = bbPed2Score(Choice2);
                        bbPed2Score3(sum(Overlap2, 2)<0.5 & sum(Overlap1, 2)<0.5) = 0;
                        bbPed2Score2 = max(bbPed2Score2, bbPed2Score3);
                        K = size(Overlap2,2);
                        N = size(Overlap2,1);
                        Ns = 0:K:N*K-1;
                        C2 = Choice2 + Ns';
                        Overlap2 = Overlap2';
                        Ol2 = Overlap2(C2);
                        K = size(Overlap1,2);
                        N = size(Overlap1,1);
                        Ns = 0:K:N*K-1;
                        C1 = Choice1 + Ns';
                        Overlap1 = Overlap1';
                        Ol1 = Overlap1(C1);
                        Conflict2 = Conflict & (Ol2(:) <= Ol1(:));
                        Conflict1 = Conflict & (Ol2(:) > Ol1(:));
                        Context2(Conflict2) = 0;
                        Context1(Conflict1) = 0;
                    end;
                    Context3 = Context1 + Context2;
                    Context3 = Context3 .* bbPed2Score2;
                    Context_Ped2_3 = Context_Ped2_3 + Context3 ;
                end;
                P2 = AdjustP2Score(DatasetChoice, INRIAExt, EvalAll, Context_Ped2_3);
            else
                P2 = 0;
            end;
            Ped1Score = bbshow(:, end);
            [a b P2] = GetABP2(DatasetChoice, EvalAll, INRIAExt, P2, a, b, alg);
            Ped1ScoreOri = Ped1Score;
            Ped1Score = Ped1Score*a+b;
            Ped1Score = 1./(1+exp(-Ped1Score));
            Score = Ped1Score.*(1 + P2*4);
            bbshow(:, end) = Score;
            bbshow2 = bbshow;
            bbshow2(:, 3:4) = bbshow2(:, 3:4) + bbshow2(:, 1:2);
        end;
    else
        Keep = [];
    end;
    bbshow = nmsMy3(bbshow, 0.5, Keep, alg);
    if DatasetChoice ~= 3
        srcName = SrcNames{i};
        dstName3 = [dstbasepath srcName(9:end)];
    else
        dstName3 = [dstbasepath Resname{i}];
    end;
    
    fid2 = fopen(dstName3, 'w');
    if (size(bbshow, 1)>0)
        fprintf(fid2, '%f, %f, %f, %f, %f\n', bbshow');
    end;
    fclose(fid2);
    
    if (mod(i, 64) == 1 && i~=1)
        fprintf('%d ', i);
    end;
    if (mod(i, 640) == 1 && i~=1)
        fprintf('\n', i);
    end;
    if (i<10) && ~isempty(bbshow)
        fprintf('%d newscore max: %.4f, min: %.4f, cands: %d\n', i, max(Score), min(Score), size(bbshow, 1));
    end;
    
end;
fprintf('Ped2Num: %f,  Ped1Num: %f\n', Ped2Num, Ped1Num);

function pick = nms_pick(boxes, overlap)
% top = nms(boxes, overlap)
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.

if isempty(boxes)
    top = [];
    pick = [];
else
    x1 = boxes(:,1);
    y1 = boxes(:,2);
    x2 = boxes(:,3);
    y2 = boxes(:,4);
    s = boxes(:,end);
    area = (x2-x1+1) .* (y2-y1+1);
    
    [vals, I] = sort(s);
    pick = [];
    while ~isempty(I)
        last = length(I);
        i = I(last);
        pick = [pick; i];
        suppress = [last];
        for pos = 1:last-1
            j = I(pos);
            xx1 = max(x1(i), x1(j));
            yy1 = max(y1(i), y1(j));
            xx2 = min(x2(i), x2(j));
            yy2 = min(y2(i), y2(j));
            w = xx2-xx1+1;
            h = yy2-yy1+1;
            if w > 0 && h > 0
                % compute overlap
                Area_Intersection = w*h;
                %         o = w * h / area(j);
                o3 = Area_Intersection / (area(i)+area(j)-Area_Intersection);
                if o3 > overlap
                    suppress = [suppress; pos];
                end
            end
        end
        I(suppress) = [];
    end
    %   top = boxes(pick,:);
end


function [ThrNew] = GetThreshold(LatSVM_Model, EvalAll)
if LatSVM_Model
    if ~EvalAll
        ThrNew = -0.5; %-0.6
    else
        ThrNew = -100; %-0.6
    end;
else
    ThrNew = -0.7; %-0.6
end;


function top = nmsMy3(boxes, overlap, Keep, alg)

% top = nms(boxes, overlap)
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.
% overlapTable = [0.65 0.7 0.75];
% overlap = overlapTable(alg.c);
if isempty(boxes)
    top = [];
else
    x1 = boxes(:,1);
    y1 = boxes(:,2);
    x2 = boxes(:,3)+boxes(:,1);
    y2 = boxes(:,4)+boxes(:,2);
    s = boxes(:,end);
    area = (x2-x1+1) .* (y2-y1+1);
    
    [vals, I] = sort(s);
    pick = [];
    SuppressNum = zeros(length(I), 1);
    picki = 0;
    while ~isempty(I)
        supressLast = 0;
        last = length(I);
        i = I(last);
        s1 = vals(last);
        pick = [pick; i];
        suppress = [last];
        for pos = 1:last-1
            j = I(pos);
            s2 = vals(pos);
            xx1 = max(x1(i), x1(j));
            yy1 = max(y1(i), y1(j));
            xx2 = min(x2(i), x2(j));
            yy2 = min(y2(i), y2(j));
            w = xx2-xx1+1;
            h = yy2-yy1+1;
            if w > 0 && h > 0
                % compute overlap
                o = w * h / area(j);
                o2 = w * h / area(i);
                
                %High first
                o = max(o2, o);
                
                o3 = w*h / (area(i)+area(j)-w*h);
                %Big first
                %         if (o2 > overlap) % && (s2>0.2)
                % %         if (o2 > overlap) && (s1>0) && (s2>0)
                %             supressLast = 1;
                %         end
                
                if o3 > 0.5
                    suppress = [suppress; pos];
                else
                    if o > overlap && ~Keep(i,j)
                        suppress = [suppress; pos];
                    end
                end;
            end
        end
        if supressLast
            pick(end) = [];
        end;
        picki = picki+1;
        SuppressNum(picki) = length(suppress);
        I(suppress) = [];
    end
    top = boxes(pick,:);
end