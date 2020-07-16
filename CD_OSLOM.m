% Author: Sarah Aliko
% Date last modified: 03/10/2019
% This code reads the tp file from OSLOM community detection algorithm
% and re-arranges it for mapping back to MNI brain

% open file tp_without_singletons, where each voxel will be forced into 
% a module. Can use tp but there will be voxels
% missing as they are not assigned a module by OSLOM
str=input('', 's')
fid=fopen(['./new_media_windo', num2str(str), '5mm.txt_oslo_files/tp_without_singletons']);
S=textscan(fid, '%s');
fclose(fid);

T = [];
T3 = [];
T2 = [];

% save module number ID and the voxels within that module into a table
% Table format is: voxel ID from afni, module ID from OSLOM
for i=1:length(S{1,1})
    if S{1,1}{i} == "#module"
        len_list = S{1,1}{i+3};
        module = S{1,1}{i+1};
        nums_list = {S{1,1}{(i+6):(i+6+str2double(len_list)-1)}};
        module_list = cell([1 str2double(len_list)]);
        module_list(:) = {module};
        T = [T; {nums_list', module_list'}];
    end
end

for j=1:length(T)
    T2 = [T2; str2double(T{j})];
    T3 = [T3; str2double(T{j+length(T)})];
end

T4 = array2table([T2 T3]);
T4 = sortrows(T4, {'Var1'});
[b,m,n] = unique(T4(:,{'Var1'}));
% get unique IDs for each voxel and sort the columns of the table by voxel
% ID. NB: some voxels belong to more than 1 module!
T4.Var1 = n;

% Load voxel coordinates xyz that are in order of voxel ID. NB: the data
% here is on unique voxels and there are no repetitions of a voxel
pos = load(['coordinates_', num2str(str), '.mat']);
xyz = pos.pos;
column = [1:height(xyz)]';
xyz.Var1 = column;

Tf = innerjoin(xyz, T4);
Tf.Var1 = [];
writetable(Tf, ['./community_map/community_structure_', num2str(str), '5mm.txt'], 'WriteVariableNames', false);




