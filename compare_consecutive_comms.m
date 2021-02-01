% Author: Sarah Aliko
% Date last modified: 31/01/2021
% This code reads the tp files of two consecutive windows from OSLOM community detection algorithm
% and tracks community changes (i.e. relabels community at timepoint 2 based on partitions of timepoint1 and tracks nodes that changed partition over time)  

fid1=fopen('community_structure_w1_5mm.txt');
fid2=fopen('community_structure_w2_5mm.txt');
S1=textscan(fid1, '%d,%d,%d,%d');
S2=textscan(fid2, '%d,%d,%d,%d');
fclose(fid1);
fclose(fid2);
S1= S1';
S2= S2';

xyz = [S1{1,1} S1{2,1} S1{3,1}]; % since the two tps are from same brain, xyz coordinates are identical
xyz = unique(xyz, 'rows');

comms1 = [S1{1,1} S1{2,1} S1{3,1} S1{4,1}]; % community labels in tp1
comms2 = [S2{1,1} S2{2,1} S2{3,1} S2{4,1}]; % community labels in tp2

[~,idx] = unique(comms1(:,1:3), 'rows');
T1 = comms1(idx,:); % removes overlapping nodes for simplicity (these are nodes in more than 1 community) ... needs implementing to account for this 

[~,idx2] = unique(comms2(:,1:3), 'rows');
T2 = comms2(idx2,:);

unique_vals = max(T1(:,4)); % total count of communities in tp1
unique_vals2 = max(T2(:,4)); % total count of communities in tp2

T1(T1==0)=unique_vals+1;
T2(T2==0)=unique_vals2+1;

node_ids = [1:length(T2)]';
community_comp = compare([node_ids T1(:,4)], [node_ids T2(:,4)]) % calls the compare function
