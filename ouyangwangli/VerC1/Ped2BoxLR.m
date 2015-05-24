Ped2_posName = 'D:\wlouyang\hog\Params\LatSVM_ped2_pos_nme_SC_DR2__bbox';
load(Ped2_posName);
MaxClusterNum = max(feats2(:, end));
PartNum = 5;
for c = 1:MaxClusterNum
% for c = 1:MaxClusterNum
    cidx =  feats2(:, end) == c;
    feats3 = feats2(cidx, :);
    GndBox1 = feats3(:, 1:4);
%     GndBox1(:, [1 3]) = GndBox1(:, [1 3]) - 500;
    GndBox12 = GndBox1;
    GndBox12(:, 3:4) = GndBox1(:, 3:4) - GndBox1(:, 1:2) +1;
%     wnew = GndBox12(:, 4) /3;
%     GndBox12(:, 1) = GndBox12(:, 1) - (wnew - GndBox12(:, 3))/2;
%     GndBox12(:, 3) = wnew;
    
    GndBox2 = feats3(:, 5:8);
%     GndBox2(:, [1 3]) = GndBox2(:, [1 3]) - 500;
    GndBox22 = GndBox2;
    GndBox22(:, 3:4) = GndBox2(:, 3:4) - GndBox2(:, 1:2) +1;
%     wnew = GndBox22(:, 4)/3;
%     GndBox22(:, 1) = GndBox22(:, 1) - (wnew - GndBox22(:, 3))/2;
%     GndBox22(:, 3) = wnew;
    PartBox = feats3(:, [9:11 13:14 17:18 21:22 25:26 29:30]);
    PartBox(:,3) = PartBox(:,3)  - PartBox(:, 1)+1;
    for i = 1:PartNum
        PartBox(:, i*2+2:i*2+3) = PartBox(:, i*2+2:i*2+3) - PartBox(:, 1:2);
    end
%     PartBox(:, 1:2) = 0;
    
    PartBox = [PartBox ones(size(PartBox, 1), 1)];
   
    GndBox12(:,1:2) = GndBox12(:,1:2)  - PartBox(:, 1:2);
    GndBox22(:,1:2) = GndBox22(:,1:2)  - PartBox(:, 1:2);
    PartBox(:, 1:2) = [];
    if c <=7
        LeftFlag = GndBox12(:,1) < GndBox22(:,1);
    else
        LeftFlag = GndBox12(:,2) < GndBox22(:,2); %| GndBox12(:,3) < GndBox22(:,3);
    end
    GndBox13 = GndBox12;
    GndBox13(LeftFlag, :) = GndBox22(LeftFlag, :);
    GndBox23 = GndBox22;
    GndBox23(LeftFlag, :) = GndBox12(LeftFlag, :);
    
    p1{c}{1}(:,1) = regress(GndBox13(:,1), PartBox);
    p1{c}{1}(:,2) = regress(GndBox13(:,2), PartBox);
    p1{c}{1}(:,3) = regress(GndBox13(:,3), PartBox);
    p1{c}{1}(:,4) = regress(GndBox13(:,4), PartBox);
    
    GndBox13(:, 5:8) = PartBox * p1{c}{1};
    Overlap = TestOverlap(GndBox13(:, 1:4), GndBox13(:, 5:8), 1);
    Overlap = diag(Overlap);
    fprintf('%d, 11: Overlap > 0.5: %.3f\n', c, sum(Overlap>0.5)/length(Overlap));
        
    GndBox14 = GndBox13(Overlap>0.5, :);
    PartBox2 = PartBox(Overlap>0.5, :);
    p{c}{1}(:,1) = regress(GndBox14(:,1), PartBox2);
    p{c}{1}(:,2) = regress(GndBox14(:,2), PartBox2);
    p{c}{1}(:,3) = regress(GndBox14(:,3), PartBox2);
    p{c}{1}(:,4) = regress(GndBox14(:,4), PartBox2);
    GndBox14(:, 5:8) = PartBox2 * p{c}{1};
    Overlap = TestOverlap(GndBox14(:, 1:4), GndBox14(:, 5:8), 1);
    Overlap = diag(Overlap);
    fprintf('%d, 12: Overlap > 0.5: %.3f\n', c, sum(Overlap>0.5)/length(Overlap));

    
    p2{c}{2}(:,1) = regress(GndBox23(:,1), PartBox);
    p2{c}{2}(:,2) = regress(GndBox23(:,2), PartBox);
    p2{c}{2}(:,3) = regress(GndBox23(:,3), PartBox);
    p2{c}{2}(:,4) = regress(GndBox23(:,4), PartBox);
    
    GndBox23(:, 5:8) = PartBox * p2{c}{2};
    Overlap = TestOverlap(GndBox23(:, 1:4), GndBox23(:, 5:8), 1);
    Overlap = diag(Overlap);
    fprintf('%d, 2: Overlap > 0.5: %.3f\n', c, sum(Overlap>0.5)/length(Overlap));
    
    GndBox24 = GndBox23(Overlap>0.5, :);
    PartBox2 = PartBox(Overlap>0.5, :);
    p{c}{2}(:,1) = regress(GndBox24(:,1), PartBox2);
    p{c}{2}(:,2) = regress(GndBox24(:,2), PartBox2);
    p{c}{2}(:,3) = regress(GndBox24(:,3), PartBox2);
    p{c}{2}(:,4) = regress(GndBox24(:,4), PartBox2);
    GndBox24(:, 5:8) = PartBox2 * p{c}{2};
    Overlap = TestOverlap(GndBox24(:, 1:4), GndBox24(:, 5:8), 1);
    Overlap = diag(Overlap);
    fprintf('%d, 12: Overlap > 0.5: %.3f\n', c, sum(Overlap>0.5)/length(Overlap));

end
BoxLR_p = p;
save('BoxLR_p', 'BoxLR_p');
