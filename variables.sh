#!/bin/bash

################################################################################
# Set experiment specific variables
################################################################################

# NOTE
# Variables currently need to be set up manually

#############################
# Movie
#############################

movie="500_days"
movie_length="5470"

#############################
# Directories
#############################

base_data_dir="/home/ucbts00/Scratch"
data_dir="$base_data_dir"/"$movie"

#############################
# Participant(s)
#############################

perp="180303JM"

#############################
# Degree centrality analysis
#############################

# Mask to use w/ 3dDegreeCentrality
# This one was made during preprocessing
mask_name="anatomical_mask"

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
thresh_value="10"
