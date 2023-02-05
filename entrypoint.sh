#!/bin/bash


download () {
    local last_run_file="$AUDIBLE_CONFIG_DIR/lastrun"
    local run_time=`date -u +%Y-%m-%dT%H:%M:%S`

    local download_opts=()
    if [ ! -z $AUDIBLE_PROFILE ]
    then 
        download_opts=(${download_opts[@]} --profile $AUDIBLE_PROFILE)
    fi

    download_opts=(${download_opts[@]} download)
    download_opts=(${download_opts[@]} --output-dir $TEMP_DOWNLOAD)
    download_opts=(${download_opts[@]} --aaxc)
    download_opts=(${download_opts[@]} --all)
    download_opts=(${download_opts[@]} --chapter)
    download_opts=(${download_opts[@]} --cover)
    download_opts=(${download_opts[@]} --cover-size 1215)
    download_opts=(${download_opts[@]} --ignore-podcasts)
    download_opts=(${download_opts[@]} --ignore-errors)

    if [ -f $last_run_file ]
    then
        local last_run=`cat $last_run_file`
        download_opts=(${download_opts[@]} --start-date $last_run)
    fi

    if [ ! -f $TEMP_DOWNLOAD ]
    then
        mkdir -p $TEMP_DOWNLOAD
    fi

    if [ ! -f $AUDIBLE_COMPLETE ]
    then
        mkdir -p $AUDIBLE_COMPLETE
    fi

    if [ ! -f $AUDIBLE_DEST ]
    then
        mkdir -p $AUDIBLE_DEST
    fi

    audible "${download_opts[@]}"
    audible library export -o $AUDIBLE_CONFIG_DIR/library.tsv

    echo $run_time > $last_run_file

    cd $TEMP_DOWNLOAD
    /aaxtomp3/AAXtoMP3 \
        --complete_dir $AUDIBLE_COMPLETE \
        --target_dir $AUDIBLE_DEST \
        --use-audible-cli-data \
        --audible-cli-library-file $AUDIBLE_CONFIG_DIR/library.tsv \
        --dir-naming-scheme '${artist//[:.]}/${series_sequence:+$series_sequence/}${title//[:.]}' \
        --file-naming-scheme '${title//[:.]}' \
        --chapter-naming-scheme '${title//[:.]}-$(printf %0${#chaptercount}d $chapternum) ${chapter//[:.]}' \
        --debug \
        *.aaxc
}

if [ "$1" == "quickstart" ] 
then
    audible quickstart
elif [ "$1" == "download" ] 
then
    if [ ! -f "$AUDIBLE_CONFIG_DIR/config.toml" ]
    then
        echo "Run quickstart first"
        exit 1
    fi

    download
else
    audible $@
fi
