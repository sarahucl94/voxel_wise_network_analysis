% Author: Sarah Aliko
% Date last modified: 03/10/2019
% This code reads the tp file from OSLOM community detection algorithm
% and re-arranges it for mapping back to MNI brain

% open file tp_without_singletons, where each voxel will be forced into 
% a module. Can use tp but there will be voxels
% missing as they are not assigned a module by OSLOM

fid1=fopen('community_structure_w1_5mm.txt');
fid2=fopen('community_structure_w2_5mm.txt');
S1=textscan(fid1, '%d,%d,%d,%d');
S2=textscan(fid2, '%d,%d,%d,%d');
fclose(fid1);
fclose(fid2);
S1= S1';
S2= S2';

xyz = [S1{1,1} S1{2,1} S1{3,1}];
xyz = unique(xyz, 'rows');

comms1 = [S1{1,1} S1{2,1} S1{3,1} S1{4,1}];
comms2 = [S2{1,1} S2{2,1} S2{3,1} S2{4,1}];

[~,idx] = unique(comms1(:,1:3), 'rows');
T1 = comms1(idx,:);

[~,idx2] = unique(comms2(:,1:3), 'rows');
T2 = comms2(idx2,:);

unique_vals = max(T1(:,4));
unique_vals2 = max(T2(:,4));

T1(T1==0)=unique_vals+1;
T2(T2==0)=unique_vals2+1;

node_ids = [1:length(T2)]';
community_comp = compare([node_ids T1(:,4)], [node_ids T2(:,4)])
