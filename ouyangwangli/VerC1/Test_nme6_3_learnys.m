function [p] = Test_nme6_3_learnys(DatasetChoice, Tchoice, dstbasepath, c, Frames, BBname, BBname_Ped2, Modelname, ModelSVMname, Choice, UseDBN, LatSVM_Model)
Choice = 0;
NoParts = 1;
ScoreAdd = 0;
global Ped2ScoreAdd;

global UsePedParts;
global Kernel_SVM;
% ContextSize= 49;
% Sel = GetSel();
Ovlap_T = 0.01;
global T_Ped2;
load('D:\wlouyang\hog\Params\INRIA_ovlpPos_MOG1_DR2.mat');
load('D:\wlouyang\hog\Params\INRIA_ovlpPos3.mat');
for i = 1:length(center)
    Centers((i-1)*3+1:i*3, :) = center{i};
    Vars((i-1)*3+1:i*3, :) = variance{i};
end;
    Modelname2 = 'D:\wlouyang\hog\Params\LatSVM-MR-20PartsS_I_model2';
    load(Modelname2);
    w1_1 = w1; w1_2 = w2; w1_3 = w3; w1_class = w_class;
load(BBname_Ped2, 'bbshowset_all');
bbset_ped2_all = bbshowset_all;
load(BBname, 'bbshowset_all');
fnum = length(bbshowset_all);
overlapVal = 0.9;
MixtureW = [0.957399103139013	0.865470852017937	1.17713004484305	0.857476635514019	1.21495327102804	0.927570093457944	0.783011583011583	0.657915057915058	1.55907335907336];
MixtureW = sqrt(MixtureW);
if Frames > 0
    fnum = min(fnum, Frames);
end;
Ped2Num = 0;
Ped1Num = 0;
ShowResults = 0;
switch DatasetChoice %0: caltech train;  1: ETHZ;  2: tudbrussels 3: Occ
    case 0
%         dstbasepath = sprintf('D:/wlouyang/Caltech_pedestrian/data-usa/res/Our-nme%02i/', c);
        load('D:\wlouyang\hog\Params\CaltechFileNames2');
    case 1
        load('D:\wlouyang\hog\Params\ETHFileNames');
        bbFileName = 'D:/wlouyang/hog/Params/Face_BB_ETH';
        load(bbFileName, 'FaceDets');
    case 2
        load('D:\wlouyang\hog\Params\tudbrussels');
    case 3
% %         c = 1;
%         dstbasepath = sprintf('D:/wlouyang/Caltech_pedestrian/data-Occ/res/Our-nme%02i/', c);
        load('D:\wlouyang\hog\Params\Occ_testFilename', 'ImagSourcepaths', 'dstbasepathParts', 'ImNames', 'Resname', 'fileNum');
    case 4
        load('D:\wlouyang\hog\Params\Caltec_TestFilename');
end;
InitT = 1;
CandNum = 500;
ys = []; hs = [];
T_Ped1 = 0.2;
for i = 1:fnum %for each frame
%bbshow: [x1 y1 w h partsscore(1:20) LatSVM_score DBN_score]
    
%         bbPed2 = bbset_ped2_all{i}(1:end-1, :);
%         bbPed2(:, bbPed2(end, :) < T_Ped2) = [];
%         bbPed2 = bbPed2';
%         if ~isempty(bbPed2)
%                     P21 = bbPed2(:, [4+2 4+4]);
%                     P22 = bbPed2(:, [4+5+2 4+5+4]);
%             y = [P21(:, 1); P22(:, 1)];
%             h = [P21(:, 2); P22(:, 2)];
%             h = h - y;
%             y = y - h;
%             ys = [ys; y];
%             hs = [hs; h];
%         end;
    bbshow = bbshowset_all{i};
    if ~isempty(bbshow)
%     bbshow(bbshow(:, end)<T_Ped1, :) = [];
%         bbshow(:, end) = bbshow(:, end) + ScoreAdd;
        y = [bbshow(:, 2) ];
        h = [bbshow(:, 4) ];
        y = y - h;
        ys = [ys; y];
        hs = [hs; h];
    end;
end;
fprintf('num of ys: %d\n', size(ys, 1));
%             p = polyfit(ys,hs,1);
            p = polyfit(hs,ys,1);
%             yfit = polyval(ps,hs);
fprintf('Ped2Num: %f,  Ped1Num: %f\n', Ped2Num, Ped1Num);

function showboxes2(im, boxes)

% showboxes(im, boxes)
% Draw boxes on top of image.

% clf;
image(im); 
axis equal;
axis on;
if ~isempty(boxes)
  numfilters = floor(size(boxes, 2)/4);
  for i = 1:numfilters
    x1 = boxes(:,1+(i-1)*4);
    y1 = boxes(:,2+(i-1)*4);
    x2 = boxes(:,3+(i-1)*4);
    y2 = boxes(:,4+(i-1)*4);
    if i == 1
      c = 'r';
    else
      c = 'b';
    end
    line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color', c, 'linewidth', 3);
  end
end
drawnow;

% function [Context] = GetBBContext(bbs)
% %bbs : nx5 matrix 
% %bbs(1, 1:5) == [x, y, w, h, score]
% 
% as=bbs(:,3).*bbs(:,4);
% n=size(bbs,1);
% xs=bbs(:,1); xe=bbs(:,1)+bbs(:,3); ys=bbs(:,2); ye=bbs(:,2)+bbs(:,4);
% overlaps = zeros(n);
% for i=1:n
%     for j=(i+1):n
%         iw=min(xe(i),xe(j))-max(xs(i),xs(j)); if(iw<=0), continue; end
%         ih=min(ye(i),ye(j))-max(ys(i),ys(j)); if(ih<=0), continue; end
%         o=iw*ih; 
% %         u=as(i)+as(j)-o; % Union of A and B
%         u=min(as(i),as(j));% min area of A and B
%         o=o/u;
%         overlaps(i,j) = o;
% %         if(o>overlap), kp(j)=0; end        
%     end
% end
% onesN = ones(n, 1);
% xe1 = xe(:, onesN);
% xe2 = xe1';
% xs1 = xs(:, onesN);
% xs2 = xs1';
% ye1 = ye(:, onesN);
% ye2 = ye1';
% ys1 = ys(:, onesN);
% ys2 = ys1';
% IW = min(xe1, xe2) - max(xs1, xs2);
% IW(IW<0) = 0;
% IH = min(ye1, ye2) - max(ys1, ys2);
% IH(IH<0) = 0;
% as1 = as(:, onesN);
% as2 = as1';
% U = min(as1 ,as2);
% O = IW .* IH;
% overlaps2 = O ./ U;
% overlaps2(overlaps2<0) = 0;
% % overlaps2 = triu(overlaps2, 1);
% diff = sum(sum(abs(overlaps - overlaps2)));
% bins = [0.5 0.6 0.7 0.8 0.9 0.95 1];
% scores = bbs(:, 5)';
% scores = scores(onesN', :);
% 
% scores2 = scores';
% KMax = 5;
% for i = 1:length(bins)-1
%    binflag = (overlaps2>=bins(i)) & (overlaps2 < bins(i+1));
%    scoreNew = binflag .* scores; %scores in this bin
%    
% %% Context set 1: Does not distiguish smaller or larger scores
%    % 1. Count the number overlapping
%    NumBins(:, i) = sum(binflag, 2);
%    NumBins2 = max(NumBins(:, i), 1);
%    
%    % 2. Sum up all scores   
%    val1(:, i) = sum(scoreNew, 2);
%    
%    % 3. Average overlapping scores
%    val2(:, i) = sum(scoreNew, 2)./NumBins2;
%    
%    % 4. Max overlapping scores
%    val3(:, i) = max(scoreNew, [], 2);
%    
%    % 5. Take K maximum overlapping scores
%    sortedScore = sort(scoreNew, 2, 'descend');
%    val4(:, (i-1)*KMax+1:i*KMax) = sortedScore(:, 1:KMax);
% 
% %% Context set 2: Distiguish smaller or larger scores
%    SmallBin = ((scoreNew - scores2)<=0) & binflag; % score smaller than current window
%    LargeBin = ((scoreNew - scores2)>0)  & binflag; % score larger than current window
%    
%    scoreSmall = SmallBin .* scores;
%    scoreLarge = LargeBin .* scores;
% 
%    % 1. Count the number overlapping
%    NumBins(:, 2*i-1) = sum(SmallBin, 2);
%    NumBins(:, 2*i)   = sum(LargeBin, 2);
%    
%    % 2. Sum up all scores   
%    val1(:, 2*i-1) = sum(scoreSmall, 2);
%    val1(:, 2*i)   = sum(scoreLarge, 2);
%    
%    % 3. Average overlapping scores
%    NumBins2 = max(NumBins(:, 2*i-1), 1);
%    val2(:, 2*i-1) = sum(scoreSmall, 2)./NumBins2;
%    NumBins2 = max(NumBins(:, 2*i), 1);
%    val2(:, 2*i) = sum(scoreLarge, 2)./NumBins2;
%    
%    % 4. Max overlapping scores
%    val3(:, 2*i-1) = max(scoreSmall, [], 2);
%    val3(:, 2*i)   = max(scoreLarge, [], 2);
%    
%    % 5. Take K maximum overlapping scores
%    sortedScore = sort(scoreSmall, 2, 'descend');
%    val4(:, (2*i-1)*KMax+1:i*KMax) = sortedScore(:, 1:KMax);
%    sortedScore = sort(scoreLarge, 2, 'descend');
%    val4(:, (2*i)*KMax+1:i*KMax) = sortedScore(:, 1:KMax);
%    
% end;
% % bbs = 1;
% Context = val4;

function pick = nms_pick2(boxes, overlap)

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
        o = w * h / area(j);
        o2 = w * h / area(i);
        %High first
        o = max(o2, o);

%         Area_Intersection = w*h;
% %         o = w * h / area(j);
%         o3 = Area_Intersection / (area(i)+area(j)-Area_Intersection);
%         if o3 > overlap
         if o > overlap
          suppress = [suppress; pos];
        end
      end
    end
    I(suppress) = [];
  end  
%   top = boxes(pick,:);
end

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

function top = nmsMy2(boxes, bbPed2, overlap, Centers, Vars)
% boxes: [x y w h]
% bbPed2: [x1 y1 x2 y2]
% top = nms(boxes, overlap) 
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.

bbPed2(:, 3:4) = bbPed2(:, 3:4) - bbPed2(:, 1:2);
boxes2 = boxes;
boxes2(:, 3:4) = boxes2(:, 3:4) + boxes2(:, 1:2);
overlaps2 = TestOverlap(boxes, bbPed2);
overlaps2 = max(overlaps2, [], 2);
RetainChoice = (overlaps2>0.8);
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
  retainNum = 0;
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
        Area_Intersection = w*h;
        o = Area_Intersection / area(j);
        o2 = Area_Intersection / area(i);
        o3 = Area_Intersection / (area(i)+area(j)-Area_Intersection);

        %High first
        o = max(o2, o);
        
        if o+0.001 < o3
            keyboard;
        end;
        
        %Big first
%         if (o2 > overlap) % && (s2>0.2)
% %         if (o2 > overlap) && (s1>0) && (s2>0)
%             supressLast = 1;
%         end

        decriptor = GetDiscriptor(boxes2(i, :), boxes2(j, :));
        Deviation = bsxfun(@minus, Centers, decriptor);
%         V = std(Deviation);
        Deviation2 = abs(Deviation) > 0.5*Vars;
%         Deviation2 = abs(Deviation) > repmat(variance{c}(i, :)*2, [size(PosFeatc, 1) 1]);
        Deviated = sum(sum(Deviation2(:, 1:3), 2)>0)>8;
        if (o > overlap) && ~( (o<0.8) && (o3 < 0.5) && RetainChoice(j) && ~Deviated )
%         if (o > overlap) && ~( (o<0.8) && (o3 < 0.5) && RetainChoice(j) && ~Deviated && ( (boxes(i,3)>=boxes(j,3)) && (boxes(i,2)>boxes(j, 2)) || (boxes(i,3)<boxes(j,3)) && (boxes(i,2)<boxes(j, 2)) ) )
%         if (o > overlap) && ~( (o<0.8) && (o3 < 0.5) && RetainChoice(j) && ~Deviated && ( (boxes(i,3)>=boxes(j,3)) && (boxes(i,2)>boxes(j, 2)) || (boxes(i,3)<boxes(j,3)) && (boxes(i,2)<boxes(j, 2)) ) )
%         if (o > overlap) && ~( (o<0.8) && (o3 < 0.5) && RetainChoice(j) && ( (boxes(i,3)>=boxes(j,3)) && (boxes(i,2)>boxes(j, 2)) || (boxes(i,3)<boxes(j,3)) && (boxes(i,2)<boxes(j, 2)) ) )
                suppress = [suppress; pos];
        else
            retainNum = retainNum + 1;
        end
      end
    end
    if supressLast
        pick(end) = [];
    end;
    picki = picki+1;
    SuppressNum(picki) = length(suppress)+retainNum;
    I(suppress) = [];
  end  
  top = boxes(pick,:);
  top(:, end)= top(:, end) + SuppressNum(picki)*0.01;
end


function descriptor = GetDiscriptor(bb1, bb2)
%bb1, bb2: [x1 y1 x2 y2]
%descriptor [-x (right) -y (right is at bottom) -s (right is smaller)]
%descriptor [ x (N/A)    y (right is at top)     s (right is larger)]
posbb(1, :) = bb1;
posbb(2, :) = bb2;
posbb2 = posbb;
posbb(:, 3:4) = posbb(:, 3:4) - posbb(:, 1:2) + 1; %w h
posbb(:, 1:2) = posbb(:, 1:2) + posbb(:, 3:4)*0.5; %center
if (posbb(1, 1) > posbb(2, 1))%make sure posbb(1, :) is on the left
    tmp = posbb(1, :);
    posbb(1, :) = posbb(2, :);
    posbb(2, :) = tmp;
    tmp = posbb2(1, :);
    posbb2(1, :) = posbb2(2, :);
    posbb2(2, :) = tmp;
end;
descriptor(1:2) = posbb(1,1:2) - posbb(2,1:2);
descriptor(3) = posbb(2, 3);%right size divide left size, >0, left is smaller, <0 left is larger
descriptor = descriptor ./ repmat(posbb(1, 3), 1, 3);
descriptor(3) = log2(descriptor(3));

function top = nmsMyP(boxes, overlap, Prob)

% top = nms(boxes, overlap) 
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.

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
        
        %Big first
%         if (o2 > overlap) % && (s2>0.2)
% %         if (o2 > overlap) && (s1>0) && (s2>0)
%             supressLast = 1;
%         end

        if o > overlap
            if Prob(i,j) < 0.6
                suppress = [suppress; pos];
            else
                dbg = 1;
            end;
        end
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
  top(:, end)= top(:, end) + SuppressNum(picki)*0.01;
end

function top = nmsMy(boxes, overlap)

% top = nms(boxes, overlap) 
% Non-maximum suppression.
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected detection.

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
        
        %Big first
%         if (o2 > overlap) % && (s2>0.2)
% %         if (o2 > overlap) && (s1>0) && (s2>0)
%             supressLast = 1;
%         end

        if o > overlap
          suppress = [suppress; pos];
        end
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
  top(:, end)= top(:, end) + SuppressNum(picki)*0.01;
end