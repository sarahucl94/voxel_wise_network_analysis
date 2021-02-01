# Voxel-wise brain network analysis pipeline

This repo contains code for analysis of large (~16k voxels and ~12m edges) brain networks. It performs a sliding-window analysis of voxel-wise connectivity.
The code was implemented on our lab's fMRI dataset, that can be found at the following: https://openneuro.org/dashboard/datasets

The pipeline starts from 5mm^3 resampled nifti (nii.gz) files. If you want info on preprocessing of brain data, please refer to my other repo: https://github.com/lab-lab/nndb

Requirements:
- MATLAB >= 2018a
- [AFNI software](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html)


You'll need to download the OSLOM algorithm for community detection from
```Lancichinetti, A., Radicchi, F., Ramasco, J. J., & Fortunato, S. (2010). Finding statistically significant communities in networks. In arXiv [physics.soc-ph]. arXiv. http://arxiv.org/abs/1012.2363```.

Ideally this code should be run on computing clusters if using large volumes of data (eg. naturalistic fMRI datasets). 
The main code is in `analysis.sh` that calls all others. The centrality and adjacency matrix are obtained from `brain_network_centrality.m`. OSLOM can be run in parallel for faster results, in which case you'll need the `compare_consecutive_comms.m` script to relabel consecutive windows, since OSLOM will start the partitioning in a different way every time. You can also run OSLOM using info from a previous timepoint, but this means running the code sequentially.


ROI-based analysis scripts coming VERY SOON....



