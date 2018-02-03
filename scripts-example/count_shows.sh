#!/bin/bash

echo ""
echo "Total number of TV Shows"
find /mnt/nas/Shows/ -maxdepth 1 -type d | wc -l
echo
