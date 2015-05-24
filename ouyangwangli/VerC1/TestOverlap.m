
function [overlaps2] = TestOverlap(S_pos, bbox, overlapVal)
% bbox: Kx4 ground truth matrix, each row: [x1 y1 w h]
% S_pos: Kx5 sample matrix, each row: [x1 y1 w h]

%         [neg pos testpos testneg]       = INRIA_dataMy_2data_Occ(7);%INRIA_dataMy4
%         pos = prepareParts(pos, 8);
%         bbox = [pos(1).x1 pos(1).y1 pos(1).x2 pos(1).y2];
%         bbox = [41 41 80 160];

YBin = [0]; XBin = [0];
BinCount = 0;
Binx = zeros(1, length(YBin)*length(XBin));
Biny = Binx;
for i = 1:length(YBin)
    for j = 1:length(XBin)
        BinCount = BinCount + 1;
        Binx(BinCount) = XBin(j);
        Biny(BinCount) = YBin(i);
    end;
end;
OnesBin = ones(length(YBin)*length(XBin), 1);

n1 = size(S_pos, 1);
n = n1*length(YBin)*length(XBin);
onesN1 = ones(n1, 1);
onesN = ones(n, 1);
% as2 = (bbox(3, :) -bbox(1, :))*(bbox(4, :)-bbox(2, :));
xs2 = bbox(:, 1)'; ys2 = bbox(:, 2)'; xe2 = bbox(:, 3)'+bbox(:, 1)'; ye2 = bbox(:, 4)'+bbox(:, 2)';
xs2 = xs2(onesN, :); ys2 = ys2(onesN, :); xe2 = xe2(onesN, :); ye2 = ye2(onesN, :);
% bbox = bbox(ones(n, 1), :);
        bbs = S_pos(:, 1:4);
n2 = size(bbox, 1);
onesN2 = ones(n2, 1);
xs=bbs(:,1); xe=bbs(:,1)+bbs(:,3); ys=bbs(:,2); ye=bbs(:,2)+bbs(:,4);

Scale = (bbs(:,3)+1)./40;
offsetx = Binx(onesN1, :).*Scale(:,OnesBin');
offsety = Biny(onesN1, :).*Scale(:,OnesBin');
xe1 = xe(:, OnesBin')+offsetx;
xs1 = xs(:, OnesBin')+offsetx;
ye1 = ye(:, OnesBin')+offsety;
ys1 = ys(:, OnesBin')+offsety;

% xe3 = xe1; xs3 = xs1; ye3 = ye1; ys3 = ys1;

xe1 = xe1(:); xs1 = xs1(:); ye1 = ye1(:); ys1 = ys1(:);

xe1 = xe1(:, onesN2');
xs1 = xs1(:, onesN2');
ye1 = ye1(:, onesN2');
ys1 = ys1(:, onesN2');

IW = min(xe1, xe2) - max(xs1, xs2)+1;
IW(IW<0) = 0;
IH = min(ye1, ye2) - max(ys1, ys2)+1;
IH(IH<0) = 0;
as1=(xe1 -xs1+1).*(ye1-ys1+1);
as2=(xe2 -xs2+1).*(ye2-ys2+1);
O = IW .* IH;
% U = min(as1 ,as2); % min area of A and B
U = as1 + as2 - O; % Union of A and B
        overlaps2 = O ./ U;
% switch overlapChoice
%     case 1
%         overlaps2 = O ./ U;
%     case 2
%         U = min(as1, as2);
%         overlaps2 = O ./ U;
% end;
% overlaps2 = max(overlaps2, [], 2);
% overlaps2 = reshape(overlaps2, n1, []);

% overlaps2(overlaps2<overlapVal) = 0;
% PosChoice = sum(overlaps2 > overlapVal, 2) > 0;
