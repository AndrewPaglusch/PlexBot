#!/bin/bash
echo 
echo "Available Admin Commands:"
ls scripts/ | sed 's|\.sh||g' | grep -v '?'
