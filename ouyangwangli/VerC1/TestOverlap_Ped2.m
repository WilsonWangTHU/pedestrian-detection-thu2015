
function [PosChoice Context2 overlaps3] = TestOverlap_Ped2(S_pos, bbox, Variance, alg)
% S_pos: Kx5 sample matrix, each row: [x1 y1 w h Score]
% bbox: Kx4 Ped2 detection matrix, each row: [x1 y1 x2 y2 Score]
% bbox = [bbox1; bbox2];
% Ped2Num = size(bbox1, 1);
global INRIAExt;
ContextLowT = 0;
if alg.DatasetChoice == 0 || alg.DatasetChoice == 4
    overlapValU = 0.55;
else
    overlapValU = 0.65;
end;
% overlapValU=0.63;
H_Low=0.8;
H_High=1/H_Low;
if isempty(bbox)
    Context2 = zeros(size(S_pos, 1), 1);
    PosChoice = zeros(size(S_pos, 1), 1);
    overlaps3 = zeros(size(S_pos, 1), 1);
    return;
end;
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

%% bbox from Ped2
n1 = size(S_pos, 1);
n = n1*length(YBin)*length(XBin);
onesN1 = ones(n1, 1);
onesN = ones(n, 1);
xs2 = bbox(:, 1)'; ys2 = bbox(:, 2)'; xe2 = bbox(:, 3)'; ye2 = bbox(:, 4)';
xs2 = xs2(onesN, :); ys2 = ys2(onesN, :); xe2 = xe2(onesN, :); ye2 = ye2(onesN, :);


%% S_pos from single det
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

Descriptor1_1 = (xs1 + xe1)./2; %from S_pos
Descriptor1_2 = ye1;
Descriptor1_3 = xe1 - xs1;

Descriptor2_1 = (xs2 + xe2)./2;%from bbox
Descriptor2_2 = ye2;
Descriptor2_3 = xe2 - xs2;


d(:, :, 1) = log2(Descriptor1_3 ./ Descriptor2_3);
d(:, :, 2) = (Descriptor1_1 - Descriptor2_1)./Descriptor2_3;
d(:, :, 3) = (Descriptor1_2 - Descriptor2_2)./Descriptor2_3;

d = d.*d;
for i = 1:3
    d(:, :, i) = d(:, :, i) ./ Variance(i);
end;
d = sum(d, 3);
d = d / 10;
d2 = exp(-d);

%% Obtain overlap and Context
IW = min(xe1, xe2) - max(xs1, xs2)+1;
IW(IW<0) = 0;
IH = min(ye1, ye2) - max(ys1, ys2)+1;
IH(IH<0) = 0;
as1=(xe1 -xs1+1).*(ye1-ys1+1);
as2=(xe2 -xs2+1).*(ye2-ys2+1);
O = IW .* IH;
U = as1 + as2 - O; % Union of A and B
overlaps2 = O ./ U;

overlaps3 = overlaps2;


H_Single = ye2 - ys2 +1;
Hratio = IH ./ H_Single;

overlaps2 = (overlaps2 > overlapValU) & (Hratio>H_Low) & (Hratio<H_High);

Context = bbox(:, end)';
if nargin >2
    a = 4;
    b = - 0.5*a;
else
    a = 4; b = - 0.5*a;
end;
ContextOri = Context;
Context = Context*a+b;
Context = 1./(1+exp(-Context));
Context = Context(onesN, :);
Context(~overlaps2) = ContextLowT;
Context = Context .* d2;
overlaps3(~overlaps2) = 0;
[Context2 PosChoice] = max(Context, [], 2);
if size(Context2, 2) == 0
    Context2(:, 1) = 0;
    PosChoice(:, 1) = 0;
end;
