#!/bin/bash
set -e

BASE_DIR=/data/output/Camera1
OUTPUT_DIR=/data/output/timelapse
DATE_DIR=$(date +'%Y-%m-%d')
TODAY_DIR="${BASE_DIR}/${DATE_DIR}"
YEAR=$(date +'%Y')
YEAR_DIR="${OUTPUT_DIR}/${YEAR}"
YEAR_TIMELAPSE=${YEAR_DIR}/stills

HOURLY_DIR=${YEAR_DIR}/hourly

# Clean up old files
find ${YEAR_DIR} -type f -mtime +7 -name '*.avi' -exec rm -- '{}' \;

TIMELAPSE_NAME=${DATE_DIR}-timelapse.avi
TIMELAPSE_FILE="${YEAR_DIR}/${TIMELAPSE_NAME}"

TIMELAPSE_YEAR=${YEAR_DIR}/${YEAR}-timelapse.avi
TIMELAPSE_HOURLY=${YEAR_DIR}/${YEAR}-hourly-timelapse.avi

echo $TODAY_DIR
ls ${TODAY_DIR}/*.jpg | wc

mkdir -p ${YEAR_DIR}
mkdir -p ${YEAR_TIMELAPSE}
mkdir -p ${HOURLY_DIR}
chmod a+rx ${YEAR_DIR}
chmod a+rx ${YEAR_TIMELAPSE}
chmod a+rx ${HOURLY_DIR}

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
#echo $FILES

# Copy the snapshot from midday
cp ${TODAY_DIR}/12-00*.jpg ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg || true
chmod a+rx ${YEAR_TIMELAPSE}/${DATE_DIR}.jpg || true

# Copy snapshots for each hour
HOURLY_FILES=$(find ${BASE_DIR}/${YEAR}-* -name "*-00-00.jpg")
#echo $HOURLY_FILES
for HOURLY_FILE in $HOURLY_FILES; do
    FIXED_DIR=${HOURLY_FILE/$BASE_DIR\//}
    FIXED_NAME=${HOURLY_DIR}/${FIXED_DIR/\//-}
    echo "Copying ${HOURLY_FILE} to ${FIXED_NAME}"
    cp ${HOURLY_FILE} ${FIXED_NAME}
done

# Remove photos which were taken in the dark
# TODO: find a better way to do this!
rm ${HOURLY_DIR}/*-*-*-00-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-01-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-02-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-03-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-04-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-05-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-06-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-07-00-00.jpg
#rm ${HOURLY_DIR}/*-*-*-08-00-00.jpg
# It is probably light from 0800 to 1600
#rm ${HOURLY_DIR}/*-*-*-16-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-17-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-18-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-19-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-20-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-21-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-22-00-00.jpg
rm ${HOURLY_DIR}/*-*-*-23-00-00.jpg

# Do the daily snaps first
rm -f $TIMELAPSE_YEAR
cat ${YEAR_TIMELAPSE}/*.jpg | ffmpeg -framerate 5  \
       -f image2pipe \
       -vcodec mjpeg \
       -i -          \
       -vcodec mpeg4 \
       -b:v 9999999  \
       -qscale:v 0.1 \
       -f avi $TIMELAPSE_YEAR
chmod a+rx $TIMELAPSE_YEAR

# Do the hourly snaps next
rm -f $TIMELAPSE_HOURLY
cat ${HOURLY_DIR}/*.jpg | ffmpeg -framerate 24  \
       -f image2pipe \
       -vcodec mjpeg \
       -i -          \
       -vcodec mpeg4 \
       -b:v 9999999  \
       -qscale:v 0.1 \
       -f avi $TIMELAPSE_HOURLY
chmod a+rx $TIMELAPSE_HOURLY

#set -e
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

