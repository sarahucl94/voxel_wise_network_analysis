#!/bin/bash

################################################################################
# Dynamic functional connectivity with 3dDegreeCentrality
################################################################################
# Author: Sarah Aliko
# Last modified: 27/01/2021

source ./variables.sh

# Set up all possible windows to run 3dDegreeCentrality over
# create array of 60sc windows to shift every 10 seconds

window_array=( )

stop_time=$(( $movie_length - $window_end ))
for ((i=0; i<$stop_time; i+="$step_size"))
do
    num_start=$((window_start + i))
    num_end=$((window_end + i))
    window_array+=( $num_start..$num_end )
done

cd "$data_dir"/"$perp"/
pwd
mkdir ./centrality
mkdir ./coreper
filename=timeseries_degreecentrality_wx.nii.gz
textname=ts_windowx_5mm.txt
orig_file=timeseries_5mm.nii.gz

printf 'Will use "%s" as filename\n' "$filename"
rm $filename

#run degree centrality
3dDegreeCentrality \
     -polort "$polort_value" \
     -sparsity "$thresh_value" \
     -mask "$mask_name"_5mm.nii.gz \
     -out1D "$textname" \
     -prefix "$filename" \
$orig_file\[${window_array["0"]}\]
echo ${window_array["0"]}

# run matlab on the output txt file generated
rm $filename
echo wx_ | matlab -nosplash -nodesktop -nodisplay -nojvm -r brain_network_centrality

# run test_coreper algorithm
while [ ! -f ./matrix_wx_.mat ]
do
   sleep 2
done

python3 run.py _wx
rm ./"$textname"
rsync -avz --remove-source-files ./matrix_wx_.mat $remote/$movie/$perp/
rsync -avz --remove-source-files ./coordinates_wx_.mat $remote/$movie/$perp/    
rsync -avz --remove-source-files ./coreper/corness_wx.csv $remote/$movie/$perp/coreper/
rsync -avz --remove-source-files ./coreper/pairid_wx.csv $remote/$movie/$perp/coreper/

titles="B C E D voxel_avg_centr"
while [ ! -f ./centrality/voxel_avg_centr_wx_5mm.txt ]
do
   sleep 2
done

# map back the centrality values to nifti MNI space
for title in $titles
do
   rm ./centrality/"$title"_wx.nii.gz
   3dUndump \
   -prefix ./centrality/"$title"_wx.nii.gz \
   -master ./$orig_file \
   -mask ./"$mask_name"_5mm.nii.gz \
   -datum float \
   -ijk ./centrality/"$title"_wx_5mm.txt
   rsync -avz --remove-source-files ./centrality/"$title"_wx_5mm.txt $remote/$movie/$perp/centrality/
   rsync -avz --remove-source-files ./centrality/"$title"_wx.nii.gz $remote/$movie/$perp/centrality/
   echo *****************"created file: " "$title"_wx.nii.gz
done      

