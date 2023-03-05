#!/bin/bash
set -e

#args input_path output_dir player

player_file=${1}
p_dir=${2}
p_name=${3}

train_frac=90
val_frac=10

split_dir=$p_dir/split

mkdir -p ${p_dir}
mkdir -p ${split_dir}

echo "${p_name} to ${p_dir}"

python 1-data_generation/split_by_player.py $player_file $p_name $split_dir/games

for c in "white" "black"; do
    python 1-data_generation/pgn_fractional_split.py $split_dir/games_$c.pgn.bz2 $split_dir/train_$c.pgn.bz2 $split_dir/validate_$c.pgn.bz2 --ratios $train_frac $val_frac

    cd $p_dir
    mkdir -p pgns
    for s in "train" "validate"; do
        mkdir -p $s
        mkdir -p $s/$c

        #using tool from:
        #https://www.cs.kent.ac.uk/people/staff/djb/pgn-extract/
        bzcat split/${s}_${c}.pgn.bz2 | pgn-extract -7 -C -N  -#1000

        cat *.pgn > pgns/${s}_${c}.pgn
        rm -v *.pgn

        #using tool from:
        #https://github.com/DanielUranga/trainingdata-tool
        cd ${s}/${c};
        trainingdata-tool -v ../../pgns/${s}_${c}.pgn
        cd ../../;
    done
    cd ../
done
