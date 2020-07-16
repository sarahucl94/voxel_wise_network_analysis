# Voxel-wise brain network analysis pipeline

This repo contains code for analysis of large (~17,000 voxels) brain networks, as well as ROI-based network analysis. It performs a sliding-window analysis of voxel-wise connectivity.
Thee code was implemented on our lab's fMRI dataset, that can be found at the following: https://openneuro.org/dashboard/datasets

The pipeline starts from 5mm^3 resampled nifti (nii.gz) files. If you want info on preprocessing of brain data, please refer to my other repo: https://github.com/lab-lab/nndb

Requirements:
- MATLAB >= 2018a
- Python >= 3.4
- [AFNI software](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html)


You'll need to install the [Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/) in MATLAB for ceentrality measures, and download the OSLOM algorithm for community detection from
```Lancichinetti, A., Radicchi, F., Ramasco, J. J., & Fortunato, S. (2010). Finding statistically significant communities in networks. In arXiv [physics.soc-ph]. arXiv. http://arxiv.org/abs/1012.2363```.

### NB: The python code referenced in the `degree_centrality2.sh` script cannot be made available because it is being used for publication soon - please refer back in few months for availability of the code!

Ideally this code should be run on computing clusters if using large volumes of data (eg. naturalistic fMRI datasets). If you have N sliding windows, your HCP submission script should contain a line like this if you want array-job submissions:

```
#$ -t 1-N

nums="$SGE_TASK_ID"

for num in $nums
do
    ar=$(($num - 1))
    sed -e "s/wx_/w"$num"_/g" -e "s/_wx/_w"$num"/g" -e "47s/0/"$ar"/g" -e "48s/0/"$ar"/g" degree_centrality2.sh|sh
done

```




