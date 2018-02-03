#!/bin/bash

echo ""
echo "Total number of Movies"
find /mnt/nas/Movies/ -maxdepth 1 -type d | wc -l
echo
