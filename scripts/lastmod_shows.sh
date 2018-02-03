#!/bin/bash

echo ""
echo "List of TV Shows modified in last 24 hours"
find /mnt/nas/Shows/ -type d -mtime -1 | sed 's|\/mnt\/nas\/Shows/||g' | sort
echo
