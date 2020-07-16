# Voxel-wise brain network analysis pipeline

This repo contains code for analysis of large (~17,000 voxels) brain networks, as well as ROI-based network analysis. 
Ideally this code should be run on computing clusters if using large volumes of data. This code was implemented on my fMRI dataset, that can be found at the following: https://openneuro.org/dashboard/datasets

The pipeline starts from 5mm^3 resampled nifti (nii.gz) files. If you want info on preprocessing of brain data, please refer to my other repo: https://github.com/lab-lab/nndb

Requirements:
- MATLAB >= 2018a
- Python >= 3.4
- AFNI software

