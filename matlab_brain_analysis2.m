% Last modified: 30/01/2021
% This code takes the textfile output of 3ddegreecentrality from AFNI and
% builds a graph. 3ddegreecentrality provides a Pearson
% correlation value for each brain voxel to every other brain voxel. We
% thresholded it to 0.2 to obtain meaningful connections (~10% density). This is the best
% estimate of connectivity in the brain. We then calculate various centrality values


% read txt file output from 3ddegreecentrality and divide it 
% into columns in a cell array
tic
str=input('', 's');
file=(['ts_windo', num2str(str), '5mm.txt'])
fid=fopen(file);
F=textscan(fid, '%d %d %d %d %d %d %d %d %f','headerlines', 6);
fclose(fid);

% transpose 9x1 cell matrix and then call columns separately as list variables
F = F';

% col1 contains edge list of voxel IDs, x,y,z are their positions and cf is Pearson's correlation between them
col1 = [F{1,1} F{2,1}];
xyz = [[F{1,1} F{3,1} F{4,1} F{5,1}];[F{2,1} F{6,1} F{7,1} F{8,1}]];
xyz = sortrows(unique(xyz, 'rows'),1); % names and coords of individual unique voxels
xyz = xyz(:,2:end);

fname=sprintf("coordinates_%s.mat", num2str(str));
save(fname, 'xyz', '-v7.3');

G=graph(string(col1(:,1)'), string(col1(:,2)')); % build graph from edge list
matrix = full(adjacency(G)); % full adjacency matrix
fname2=sprintf("matrix_%s.mat", num2str(str));
save(fname2, 'matrix', '-v7.3');

node_ids = str2double(table2array(G.Nodes(:,1)));
[~,idx] = sort(node_ids(:,1));
D = [node_ids centrality(G, 'degree')];
E = [node_ids centrality(G, 'eigenvector')];
B = [node_ids centrality(G, 'betweenness')];
C = [node_ids centrality(G, 'closeness')];

D = D(idx,:);
E = E(idx,:);
B = B(idx,:);
C = C(idx,:);
conc_arrays = cat(2, normalize(E(:,2)), normalize(D(:,2)), normalize(B(:,2)), (normalize(C(:,2))));

% join the centrality values together in a table and avg them by row
avg_centr = array2table(mean(conc_arrays, 2));

% put all centrality values in a table
D_tot = cat(2, array2table(xyz), array2table(D(:,2)));
B_tot = cat(2, array2table(xyz), array2table(B(:,2)));
C_tot = cat(2, array2table(xyz), array2table(C(:,2)));
E_tot = cat(2, array2table(xyz), array2table(E(:,2)));
pos_mean_array = cat(2, array2table(xyz), avg_centr);

writetable(D_tot, ['./centrality/D_', num2str(str), '5mm.txt'], 'WriteVariableNames', false);
writetable(E_tot, ['./centrality/E_', num2str(str), '5mm.txt'], 'WriteVariableNames', false);
writetable(B_tot, ['./centrality/B_', num2str(str), '5mm.txt'], 'WriteVariableNames', false);
writetable(C_tot, ['./centrality/C_', num2str(str), '5mm.txt'], 'WriteVariableNames', false);
writetable(pos_mean_array, ['./centrality/voxel_avg_centr_', num2str(str), '5mm.txt'],'WriteVariableNames', false);

toc
