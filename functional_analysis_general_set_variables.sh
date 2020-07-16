#!/bin/bash

################################################################################
# Set experiment specific variables
################################################################################

# NOTE
# Variables currently need to be set up manually

#############################
# Movie Stimulus
#############################

# 500 Days of Summer
movie="500_days"
movie_length="5470"

#############################
# Directories
#############################

# Base data and data
base_data_dir="/path/to/dir"
data_dir="$base_data_dir"/"$movie"

#############################
# Participant(s)
#############################

# Participant(s) to process
participants="XXX"

#############################
# Degree centrality analysis
#############################

# NOTE
# Does dynamic functional connecitvity w/ 3dDegreeCentrality

# File type to use w/ 3dDegreeCentrality
# Possible: norm polort norm_polort norm_polort_motion norm_polort_motion_wm_ventricle
file_type="norm_polort_motion_wm_ventricle_timing_ica_5mm"

# Blur amount of file to use w/ 3dDegreeCentrality
functional_blur_amount="6"

# Mask to use w/ 3dDegreeCentrality
# This one was made during preprocessing
mask_name="anatomical_mask_no_wm_ventricle_5mm"

# Correlation window size for 3dDegreeCentrality
# Literature apparently suggests 40-60 seconds optimal
# Note that movie_length must be set above as this is used to determine the last possible 60 window (an alternate would be to have ever decreasing 
#windows until the end...)
# For 60 seconds:
window_start="0"
window_end="59"
step_size="10"

# Polort and R threshold values for 3dDegreeCentrality
polort_value="-1"
thresh_value=".1"
