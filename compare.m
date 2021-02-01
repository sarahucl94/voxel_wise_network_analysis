function communities = compare(A1, A2)

[~,idx2] = sort(A2(:,2)); % sort community partition labels
[~,idx1] = sort(A1(:,2));
A2_2 = A2(idx2,:); % sort all rows based on community labels
A1_2 = A1(idx1,:);
coms_A1 =mat2cell(A1_2(:,1)',1, histcounts(findgroups(A1_2(:,2)'))); % partition data into groups of communities
coms_A2 =mat2cell(A2_2(:,1)',1, histcounts(findgroups(A2_2(:,2)')));

% go through each community group and measure jaccard index
% jaccard over 50% means same community here (this is arbitrary)

labels_T1 = length(unique(A1(:,2)));

communities = [A1 zeros(size(A1,1),1)];
for i = 1:size(coms_A1,2)
   for j = 1:size(coms_A2,2)
      if length(intersect(coms_A1{1,i},coms_A2{1,j}))/length(union(coms_A1{1,i},coms_A2{1,j}))*100 >= 50
          added = setdiff(coms_A2{1,j}, coms_A1{1,i}); % obtain nodes that were added to a community in T2
          T2_nodes = [intersect(coms_A1{1,i},coms_A2{1,j}) added]; % nodes in T2 from same group from T1
          same_node_id = T2_nodes(1); % node that didn't change assignment
          community_label_T1 = A1(same_node_id, 2); % community label from T1
          communities(T2_nodes, 3) = community_label_T1;
      end
   end
end

idx = find(communities(:,3)==0); % are there communities with no label?
for j = 1:size(coms_A2,2)
    new_comm = intersect(coms_A2{1,j}, idx); % which "lone" nodes intersect communities in T2
    if isempty(new_comm) == 0
       communities(new_comm, 3) = labels_T1+1; % label new communities from next number not in T1
       labels_T1 = labels_T1+1;
    end
end



