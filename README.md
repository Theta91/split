split.sh is a command-line utility that splits ape, wav and flac files based on
a cuesheet, transcodes them to flac (at compression level 8), adds tags based on
the metadata in the cuesheet and renames them based on the tags (in the form
%tracknumber% %tracktitle%).

Usage
-----

To use split.sh, you must have, at minimum, shntool, flac and cuetools installed.
In addition, you must have the script cuetag installed as /usr/bin/cuetag.sh.
Some distributions install it as /usr/bin/cuetag; if your distribution does this,
you must run ln -s /usr/bin/cuetag /usr/bin/cuetag.sh or adjust the script
appropriately. If you want to split ape images, you must have mac installed.

split.sh requires one cue file and one image file per folder. The cue file must
be in the same folder as the image file you wish to split, but can be called
anything.

To use split, simply provide one or more top-level paths as arguments (no
relative paths or hard links). These top-level paths can be a single folder with
one image file or a directory containing numerous folders of images you wish to
split. Theoretically, you can include as many paths as you'd like.

It would be wise not to include any paths that contain ape, flac or wav files
that don't need to be split. Nothing bad should happen, but you'll get a lot of
complaints.

Don't worry too much about the accuracy of metadata in the cuesheet. Any half
decent tagging program will be able to fix problems easily.
