#!/bin/bash
#
# ANSI Art Animation player; by BruXy 2019
#
ANIMATION=https://16colo.rs/pack/acdu1092/raw/BRTRACD2.ANS
SPEED='.01' # wait this time each line

# 1. Disable cursor
printf "\e[?25l"

# 2. Download, convert, display slow == play animation
curl --silent $ANIMATION | \
    iconv -f cp437 -t utf-8  | \
    awk "{system(\"sleep $SPEED\");print}"

# 3. Enable cursor settings
printf "\e[?12l\e[?25h"

