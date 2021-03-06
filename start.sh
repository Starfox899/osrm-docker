#!/bin/bash
DATA_PATH=${DATA_PATH:="/data"}

_sig() {
  kill -TERM $child 2>/dev/null
}

trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

if [ ! -f $DATA_PATH/$1.osrm ]; then
  if [ ! -f $DATA_PATH/$1.osm.pbf ]; then
    wget -O $DATA_PATH/${1}.osm.pbf ${2}
    wget -O $DATA_PATH/${1}.osm.pbf.md5 ${2}.md5
    echo `gawk -F" " '{ print $1 }' $DATA_PATH/$1.osm.pbf.md5 ` $DATA_PATH/$1.osm.pbf > $DATA_PATH/$1.osm.pbf.md5
    md5sum -c $DATA_PATH/$1.osm.pbf.md5
    reteval=$?
    if [ ${reteval} -ne 0 ]; then
        exit 1;
    fi
  fi
  ./osrm-extract $DATA_PATH/$1.osm.pbf
  ./osrm-prepare $DATA_PATH/$1.osrm
  rm $DATA_PATH/$1.osm.pbf
fi

./osrm-routed $DATA_PATH/$1.osrm --max-table-size 8000 &
child=$!
wait "$child"
