#!/bin/sh

# arguments:
#  -l : first compile language grammars in directory
#  -t : first compile transform grammars in directory
#  -o : output directory
#  -b : intermediate build directory
#  -s : Elm source dir
#  -O : optimize

static_dir="docs"
build_dir="build"
elm_dir="src"

optimize=false


while getopts ":o:b:s:O" opt; do
    case $opt in
        o)
            static_dir=$OPTARG
            ;;
        b)
            build_dir=$OPTARG
            ;;
        s)
            elm_dir=$OPTARG
            ;;
        O)
            optimize=true
            ;;
        \?)
           echo "Invalid option: -$OPTARG" >&2
           exit 1
           ;;
    esac
done


# Adapted from optimize.sh in the Elm tutorial
# (https://guide.elm-lang.org/optimization/asset_size.html)

elm="${elm_dir}/Main.elm"
js="${build_dir}/main.js"
min="${static_dir}/main.min.js"


echo "Compiling Elm to JS"

if [ $optimize = true ]
then
    elm make --optimize --output=$js $elm || { exit 1; }

    echo "Optimizing JS"
    
    echo "Compiled size: $(cat $js | wc -c) bytes  ($js)"

    uglifyjs $js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=$min

    echo "Minified size: $(cat $min | wc -c) bytes  ($min)"
    echo "Gzipped size:  $(cat $min | gzip -c | wc -c) bytes"
else
    elm make --output=$js $elm || { exit 1; }
    cp $js $min
fi
