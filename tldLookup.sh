#!/bin/bash

shopt -s extglob

host -t ns "${1#*.}" | awk '{print $4}' | while read line ; do dig NS @$line ${1} ; done
