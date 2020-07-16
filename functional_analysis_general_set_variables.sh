#!/bin/bash

################################################################################
# Set experiment specific variables
################################################################################

# NOTE
# Variables currently need to be set up manually

#############################
# Movie
#############################

# 500 Days of Summer
movie="500_days"
movie_length="5470"

# CitizenFour
# Length = 01:53:24.51 = ((60+53)*60)+2 = 6805
# I can confirm that the concatenated timeseries = 6805
#movie="citizenfour"
#movie_length="6805"

# Split
# movie="split"

#############################
# Directories
#############################

# Base data and data
# On server:
base_data_dir="/cluster/project9/brain_graphs"
data_dir="$base_data_dir"/"$movie"

# Stimuli
# media_dir="$data_dir"/stimulus

#############################
# Participant(s)
#############################

# Participant(s) to process
perps="180303JM"

#############################
# Degree centrality analysis
#############################

# NOTE
# Currently these used for t/sICA also
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
