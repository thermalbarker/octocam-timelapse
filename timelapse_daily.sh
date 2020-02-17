#!/bin/bash

BASE_DIR=/data/output/Camera1
DATE_DIR=$(date +'%Y-%m-%d')
TODAY_DIR="${BASE_DIR}/${DATE_DIR}"

YEAR_DIR="${BASE_DIR}/$(date +'%Y')"
YEAR_TIMELAPSE=${YEAR_DIR}/timelapse

TIMELAPSE_NAME=${DATE_DIR}-timelapse.avi
TIMELAPSE_FILE="${YEAR_DIR}/${TIMELAPSE_NAME}"

echo $TODAY_DIR
ls ${TODAY_DIR}/*.jpg | wc

mkdir -p ${YEAR_DIR}
mkdir -p ${YEAR_TIMELAPSE}

# Calculate the files between sunrise and sunset
python /data/output/scripts/sunrise.py > /tmp/suntimes.txt
SUNRISE=$(cat /tmp/suntimes.txt | head -n 2 | tail -n 1)
SUNSET=$(cat /tmp/suntimes.txt | head -n 3 | tail -n 1)
NOON=$(cat /tmp/suntimes.txt | head -n 4 | tail -n 1)

if [ "$SUNRISE" -eq "0" ]; then
   SUNRISE=""
else
   SUNRISE="-mmin -$SUNRISE"
fi

if [ "$SUNSET" -eq "0" ]; then
   SUNSET=""
else
   SUNSET="-mmin +$SUNSET"
fi

FILES=$(find $TODAY_DIR -name '*.jpg' $SUNRISE $SUNSET | sort)
echo $FILES

# Copy the snapshot from midday

cp ${TODAY_DIR}/12-00*.jpg ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg
chmod a+rx ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg

set -e
rm -f $TIMELAPSE_FILE
cat $FILES | ffmpeg -framerate 10  \
       -f image2pipe \
       -vcodec mjpeg \
       -i -          \
       -vcodec mpeg4 \
       -b:v 9999999  \
       -qscale:v 0.1 \
       -f avi $TIMELAPSE_FILE
#-c:v libx264
#-vcodec mpeg

chmod a+rx $TIMELAPSE_FILE

#rm -rf ${TODAY_DIR}/*.jpg

TIMELAPSE_YEAR=${YEAR_TIMELAPSE}/$(date +'%Y')-timelapse.avi
rm -f $TIMELAPSE_YEAR
cat ${YEAR_TIMELAPSE}/*.jpg | ffmpeg -framerate 5  \
       -f image2pipe \
       -vcodec mjpeg \
       -i -          \
       -vcodec mpeg4 \
       -b:v 9999999  \
       -qscale:v 0.1 \
       -f avi $TIMELAPSE_YEAR

