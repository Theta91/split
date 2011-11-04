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
files=( $(find "${!#}" -name "*$ext" -type f -print) )

for (( c=0; c<${#files[@]}; c++ ))
do
  dir="$(dirname ${files[$c]})"
  cd "${dir}"
  cuebreakpoints *.cue | shnsplit -P pct -O never -o 'flac flac -8 -o %f -' "${files[$c]}"
  ntcue="$(awk '$0 ~ "TRACK" {var = $0} END { print var }' *.cue | awk -F " " '{ print $2 }' | sed 's/^[0]//g')"
  ntsplit="$(ls -1 split-track*.flac | wc -l)"
  if [[ $ntcue -eq $ntsplit ]]; then
    rm "${files[$c]}"
    cuetag.sh *.cue split-track*.flac
    for i in $(ls split-track*.flac)
    do
      t=$(echo ${i:11:2} | sed 's/^[0]//')
      track_title="$(metaflac --list $i | awk -F '=' 'tolower($0) ~ /title/ { print $2 }' | sed 's/\//_/' | sed 's/:/-/')"
      mv $i $(printf "%02d %s.flac" "${t}" "${track_title}")
    done
  fi
done
################################################################################
