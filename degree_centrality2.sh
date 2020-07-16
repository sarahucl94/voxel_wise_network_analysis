#!/bin/bash

################################################################################
# Dynamic functional connectivity with 3dDegreeCentrality
################################################################################
# Author: Sarah Aliko
# Last modified: 25/02/2020

# The code runs 3dDegreeCentrality on AFNI and outputs textfile
# of 'v1 v2 i j k i2 j2 k2 corr' format
# then sends the output to MATLAB for centrality measures calculations and
# to OSLOM for community detection
# File is finally deleted after all centralities are calculated

source ./functional_analysis_general_set_variables.sh

# Set up all possible windows to run 3dDegreeCentrality over
# create array of 60sec windows to shift every 10 seconds

window_array=( )

stop_time=$(( $movie_length - $window_end ))
for ((i=0; i<$stop_time; i+="$step_size"))
do
    num_start=$((window_start + i))
    num_end=$((window_end + i))
    window_array+=( $num_start..$num_end )
done

for perp in $perps
do
    cd "$data_dir"/"$perp"/
    mkdir ./community_map
    mkdir ./map_back_nifti
    mkdir ./coreper
    filename=media_all_tshift_despike_reg_al_mni_mask_blur"$functional_blur_amount"_"$file_type"_degreecentrality_wx.nii.gz
    textname=media_windowx_5mm.txt
    
    rm "$filename"
    printf 'Will use "%s" as filename\n' "$filename"
    #run degree centrality
    3dDegreeCentrality \
       -polort "$polort_value" \
       -thresh "$thresh_value" \
       -mask "$mask_name".nii.gz \
       -out1D "$textname" \
       -prefix "$filename" \
    media_all_tshift_despike_reg_al_mni_mask_blur"$functional_blur_amount"_"$file_type".nii.gz\[${window_array["0"]}\]
    echo ${window_array["0"]}

    # run matlab on the output txt file generated
    echo wx_ | matlab -nosplash -nodesktop -nodisplay -nojvm -r matlab_brain_analysis & sed -e '1,6d' media_windowx_5mm.txt |cut -d " " -f 1-2 > new_media_windowx_5mm.txt

    
    #run OSLOM community detection and matlab code to re-format outputs
    ./oslom_undir -cp 0 -t 0.001 -uw -singlet -fast -f new_media_windowx_5mm.txt
    echo wx_ | matlab -nosplash -nodesktop -nodisplay -nojvm -singleCompThread -r CD_OSLOM
    scp -r new_media_windowx_5mm.txt_oslo_files/ ucbts00@live.rd.ucl.ac.uk:/mnt/gpfs/live/ritd-ag-project-rd00dq-jiski83/$movie/$perp/

    titles="BC CC EC DN voxel_tot_centr"
    while [ ! -f ./map_back_nifti/voxel_tot_centr_wx_5mm.txt ]
    do
      sleep 2
    done
    # map back the centrality values to nifti MNI space
    
    for title in $titles
    do
      rm ./map_back_nifti/"$title"_wx.nii.gz
      3dUndump \
      -prefix ./map_back_nifti/"$title"_wx.nii.gz \
      -master ./media_all_tshift_despike_reg_al_mni_mask_blur"$functional_blur_amount"_"$file_type".nii.gz \
      -mask ./"$mask_name".nii.gz \
      -datum float \
      -ijk ./map_back_nifti/"$title"_wx_5mm.txt
      scp ./map_back_nifti/"$title"_wx_5mm.txt ucbts00@live.rd.ucl.ac.uk:/mnt/gpfs/live/ritd-ag-project-rd00dq-jiski83/$movie/$perp/map_back_nifti/
      scp ./map_back_nifti/"$title"_wx.nii.gz ucbts00@live.rd.ucl.ac.uk:/mnt/gpfs/live/ritd-ag-project-rd00dq-jiski83/$movie/$perp/map_back_nifti/
      echo *****************"created file: " "$title"_wx.nii.gz
    done
    
    while [ ! -f ./community_map/community_structure_wx_5mm.txt ]
    do
      sleep 2
    done
        # map community files back to MNI space
    rm ./community_map/community_structure_wx.nii.gz
    3dUndump \
      -prefix ./community_map/community_structure_wx.nii.gz \
      -master ./media_all_tshift_despike_reg_al_mni_mask_blur"$functional_blur_amount"_"$file_type".nii.gz \
      -mask ./"$mask_name".nii.gz \
      -datum float \
      -ijk ./community_map/community_structure_wx_5mm.txt
    scp  ./community_map/community_structure_wx.nii.gz ucbts00@live.rd.ucl.ac.uk:/mnt/gpfs/live/ritd-ag-project-rd00dq-jiski83/$movie/$perp/community_map/
    echo *****************"created file: " community_structure_wx.nii.gz
    rm ./community_map/community_structure_wx_5mm.txt
done
rm media_windowx_5mm.txt & rm new_media_windowx_5mm.txt
rm matrix*mat & rm coordinates*mat
titles="BC CC EC DN voxel_tot_centr"
for title in $titles
do
   rm ./map_back_nifti/"$title"_wx.nii.gz
   rm ./map_back_nifti/"$title"_wx_5mm.txt
done
rm media_all_tshift_despike_reg_al_mni_mask_blur"$functional_blur_amount"_"$file_type"_degreecentrality_wx.nii.gz
rm -rf new_media_windowx_5mm.txt_oslo_files/
