#!/bin/bash -

################################################################################
#    Copyright (C) 2011 Someone                                                #
#                                                                              #
#    This program is free software: you can redistribute it and/or modify      #
#    it under the terms of the GNU General Public License as published by      #
#    the Free Software Foundation, either version 3 of the License, or         #
#    (at your option) any later version.                                       #
#                                                                              #
#    This program is distributed in the hope that it will be useful,           #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#    GNU General Public License for more details.                              #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.     #
################################################################################

################################################################################
case "$1" in
  "" | "-h" | "--help" )
    echo -e "Usage:"
    echo -e "  split.sh [option] [top-level directory]\n"

    echo -e "split.sh splits ape, wav or flac files based on a cuesheet, transcodes them to flac,"
    echo -e "tags them based on the cuesheet, and renames the files according to track number"
    echo -e "and title.\n"

    echo -e "Options:"
    echo -e "  -ape\t\tsplit ape files"
    echo -e "  -flac\t\tsplit flac files"
    echo -e "  -h  --help\tprint this help and exit"
    echo -e "  -wav\t\tsplit wav files"
    exit 0
  ;;
  "-ape" | "-flac" | "-wav" )
    ext=.${1#-}
  ;;
  * )
    echo -e "Invalid option. For help, use split --help"
  ;;
esac
################################################################################
if [[ ! -d "${!#}" || -h "${!#}" ]]
then
  echo -e "Directory does not exist or is a symbolic link. For help, use 'split.sh --help'"
  exit 1
fi
################################################################################
IFS=$'\n'
files=( $(find "${!#}" -name *$ext -type f -print) )

for (( c=0; c<${#files[@]}; c++ ))
do
  dir="$(dirname ${files[$c]})"
  mkdir "${dir}/converted"; cd "${dir}/converted"
  cuebreakpoints ../*.cue | shnsplit -P pct -O never -o 'flac flac -8 -o %f -' "${files[$c]}"
  cuetag.sh ../*.cue split-track*.flac
  for (( t=1; t<=$(find "${dir}/converted" -type f -print | wc -l); t++ ))
  do
    t0=$(printf %02d $t)
    track_number[$t]="$(metaflac --list split-track${t0}.flac | awk -F "=" 'tolower($0) ~ /tracknumber/ { print $2 }' | sed 's/[^0-9]//')"
    track_title[$t]="$(metaflac --list split-track${t0}.flac | awk -F "=" 'tolower($0) ~ /title/ { print $2 }' | sed 's/\//_/' | sed 's/:/-/')"
    mv split-track${t0}.flac $(printf "%02d %s.flac" "${track_number[$t]}" "${track_title[$t]}")
  done
done
################################################################################
