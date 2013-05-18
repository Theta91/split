#!/bin/bash -

################################################################################
case "$1" in
  "" | "-h" | "--help" )
    echo -e "Usage:"
    echo -e "  split.sh [top-level path(s)]\n"

    echo -e "split.sh splits ape, wav and flac files based on a cuesheet, transcodes them to flac,"
    echo -e "tags them based on the cuesheet, and renames the files according to track number"
    echo -e "and title.\n"

    exit 0
  ;;
  * )
    for path in $@
    do
      if [[ ! -d "$path" || -h "$path" ]]
      then
        echo -e "$path does not exist or is a symbolic link. For help, use 'split.sh --help'"
      exit 1
      fi
    done
  ;;
esac
################################################################################
IFS=$'\n'
if [[ $(which mac) == 0 ]]
then
  ape='-name "*.ape" -o'
fi
files=( $(find "$@" \( "$ape" -name "*.flac" -o -name "*.wav" \) -type f -print) )

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
