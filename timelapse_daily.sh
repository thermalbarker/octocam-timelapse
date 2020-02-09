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

# Copy the snapshot from midday
cp ${TODAY_DIR}/12-00*.jpg ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg
chmod a+rx ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg

#set -e
rm -f $TIMELAPSE_FILE
cat ${TODAY_DIR}/*.jpg | ffmpeg -framerate 10  \
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















