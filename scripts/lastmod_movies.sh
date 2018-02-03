#!/bin/bash

echo ""
echo "List of Movies modified in last 24 hours"
find /mnt/nas/Movies/ -type d -mtime -1 | sed 's|\/mnt\/nas\/Movies/||g' | sort
echo
