% Last modified: 04/10/2019
% This code takes the textfile output of 3ddegreecentrality from AFNI and
% builds an adjacency matrix. 3ddegreecentrality provides a Pearson
% correlation value for each brain voxel to every other brain voxel. We
% thresholded it to 0.1 to obtain meaningful connections. This is the best
% estimate of connectivity in the brain.

% From the adjacency matrix, various centrality measures are calculated
% (eigenvector, betweenness, closeness and degree) using the Brain
% Connectivity Toolbox algorithms. Finally community detection is applied
% using a stochastic block model algorithm.


% Community detection: Lancichinetti, A., Radicchi, F., Ramasco, J. J. & 
%                      Fortunato, S. Finding Statistically 
%                      Significant Communities in Networks. 
%                      PLoS One 6, e18961 (2011)

% BCT package: Complex network measures of brain connectivity: Uses and 
%              interpretations. Rubinov M, Sporns O (2010) NeuroImage 
%              52:1059-69. 


% read txt file output from 3ddegreecentrality and divide it 
% into columns in a cell array
str=input('', 's');
file=(['media_windo', num2str(str), '5mm.txt'])
fid=fopen(['media_windo', num2str(str), '5mm.txt']);
E=textscan(fid, '%d %d %d %d %d %d %d %d %f','headerlines', 6);
fclose(fid);

% transpose 9x1 cell matrix and then call columns separately as list variables
E = E';

% col1 and col2 are the voxel IDs, x,y,z are their positions and cf is Pearson's correlation between them
col1 = [E{1,1}];
col2 = [E{2,1}];
x1 = [E{3,1}];
y1 = [E{4,1}];
z1 = [E{5,1}];
x2 = [E{6,1}];
y2 = [E{7,1}];
z2 = [E{8,1}];

% merge all columns and then separate into following 4 columns: voxels, x, y, z
% so that all voxels are in one single columns and all positions are in single columns respectively
voxel_int = [col1(:), col2(:), x1(:), x2(:), y1(:), y2(:), z1(:), z2(:)];
voxel_int = reshape(voxel_int, [], 4);

% re-assign voxel IDs as small integers. This is because MATLAB cannot
% operate on large ID numbers that 3ddegreecentrality spits out.
% MATLAB considers original voxel IDs as matrix sizes and crashes because they are too large
col_int = grp2idx(voxel_int(:,1));

% reshape the voxel ID column so that voxels are split into voxel1 and voxel2 to create adj matrix
col_reshaped = reshape(col_int(:), length(col1(:)), []);

% put all the new node IDs and positions in one matrix called col_mat1
x_val = reshape(voxel_int(:,2), length(col1(:)), []);
y_val = reshape(voxel_int(:,3), length(col1(:)), []);
z_val = reshape(voxel_int(:,4), length(col1(:)), []);
col_mat1 = [col_reshaped(:,1), col_reshaped(:,2), x_val(:,1), y_val(:,1), z_val(:,1), x_val(:,2), y_val(:,2), z_val(:,2)];

% sort voxels and their positions from smallest ID value of voxel1
% sort the whole matrix using the sort indices created. Also sort the corr values cf
[~,idx] = sort(col_mat1(:,1));
sorted_cols1 = col_mat1(idx,:);

% calculate number of unique voxel IDs. This is to avoid having repetitive voxel values
unique_val = unique(sorted_cols1(:,[1:2]));
tot = size(unique_val);

%create an adj and a corr matrix of zeros of size tot x tot
matrix = zeros(tot(1));

% split voxels into v1 and v2 arrays
v1 = sorted_cols1(:,1);
v2 = sorted_cols1(:,2);


% save positions of voxel1 and voxel2 in x,y,z vectors
% create an array containing all voxels together for later
x = [sorted_cols1(:,3); sorted_cols1(:,6)];
y = [sorted_cols1(:,4); sorted_cols1(:,7)];
z = [sorted_cols1(:,5); sorted_cols1(:,8)];
voxels = [v1; v2];

% replace adjacency matrix zeros with a 1 when v1 and v2 are next to each other, ie have same index
% Do the same in reverse because matrix is simmetrical and graph is undirected
% replace correlation matrix zeros with correlation values from cf array
for i = 1:length(v1)
    matrix(v1(i),v2(i)) = 1;
    matrix(v2(i),v1(i)) = 1;
end

fmatrix = sprintf("matrix_%s.mat", num2str(str));
%fmat = sprintf("matrix_%s.1D", num2str(str));
save(fmatrix, 'matrix', '-v7.3')
% dlmwrite(fmat, matrix, 'delimiter','\t','newline','pc');

% create map object of (voxels, positions) as (key, values)
% this is so you can later map voxels back to MNI space
x_pos = containers.Map(voxels, x);
y_pos = containers.Map(voxels, y);
z_pos = containers.Map(voxels, z);

G=graph(matrix);
% Degree centrality of graph from BCT script functions
D_node = degrees_und(matrix);
%Eigenvector centrality of graph from BCT
E_centr = eigenvector_centrality_und(matrix);
% Betweenness centrality of graph from BCT
B_centr = betweenness_bin(matrix);
% Closeness centrality of graph from built-in MATLAB functions
C_centr = centrality(G, 'closeness');


% turn xyz positions into cells
x = cell2table(transpose(values(x_pos)));
y = cell2table(transpose(values(y_pos)));
z = cell2table(transpose(values(z_pos)));

% save the xyz voxel coordinates as ijk so they can be mapped
% back to nifti files volumetric space
x.Properties.VariableNames = {'i'};
y.Properties.VariableNames = {'j'};
z.Properties.VariableNames = {'k'};

% need to transpose DN and BC cause they come out as a row vector and not
% as column vector
DN = transpose(D_node);
BC = transpose(B_centr);

% join the centrality values together in a table and sum them up by row
conc_arrays = cat(2, normalize(E_centr), normalize(DN), normalize(BC), (normalize(C_centr)));
avg_centr = array2table(mean(conc_arrays, 2));
avg_centr.Properties.VariableNames = {'value'};

% put all centrality values in a table
DN_tot = cat(2, x, y, z, array2table(DN));
BC_tot = cat(2, x, y, z, array2table(BC));
CC_tot = cat(2, x, y, z, array2table(C_centr));
EC_tot = cat(2, x, y, z, array2table(E_centr));

writetable(DN_tot, ['./map_back_nifti/DN_', num2str(str), '5mm.txt'], 'WriteVariableNames', false)
writetable(EC_tot, ['./map_back_nifti/EC_', num2str(str), '5mm.txt'], 'WriteVariableNames', false)
writetable(BC_tot, ['./map_back_nifti/BC_', num2str(str), '5mm.txt'], 'WriteVariableNames', false)
writetable(CC_tot, ['./map_back_nifti/CC_', num2str(str), '5mm.txt'], 'WriteVariableNames', false)


% join the ijk positions to the centrality sum array 
% make sure that the array types are all the same!
pos_mean_array = cat(2, x, y, z, avg_centr);
pos = cat(2, x, y, z);
fname=sprintf("coordinates_%s.mat", num2str(str))
%fname
save(fname, 'pos', '-v7.3')

writetable(pos_mean_array, ['./map_back_nifti/voxel_tot_centr_', num2str(str), '5mm.txt'],'WriteVariableNames', false)

