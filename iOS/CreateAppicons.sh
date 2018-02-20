#!/bin/sh

SCRIPT_FILE="CreateAppicons.sh"
SCRIPT_SOURCE="https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/${SCRIPT_FILE}"

echo "Running AppiconScript v1.1 (20. February 2018)"

if [[ $1 == "-u" ]] ; then
    echo ""
    echo  "Updating ${SCRIPT_FILE}";
    curl -L $SCRIPT_SOURCE?$(date +%s) -o $0
    exit 1
fi


APPICON_SET_PATH=$1
APPICON_SOURCE_PATH=$2
DEBUG_LAYER_SOURCE_PATH=$3
APPICON_PATH="${APPICON_SOURCE_PATH}/Appicon.png"
DEBUG_LAYER_PATH="${DEBUG_LAYER_SOURCE_PATH}/Debug.png"

echo $APPICON_PATH
echo $DEBUG_LAYER_PATH

case "$OTHER_SWIFT_FLAGS" in
    *DEBUG_MODULES*)
        if [ ! -d "${PROJECT_DIR}/build" ]; then
            mkdir ${PROJECT_DIR}/build
        fi

        IMAGE_NAME_PATH="${APPICON_SOURCE_PATH}/Generated/"

        mkdir -p $IMAGE_NAME_PATH

        IMAGE_NAME="${IMAGE_NAME_PATH}/Appicon-Debug.png"

        bg_size=`identify -format '%wx%h' "${APPICON_PATH}"`
        convert -size $bg_size -composite "${APPICON_PATH}" "${DEBUG_LAYER_PATH}" -geometry $bg_size+0+0 -depth 8 "${IMAGE_NAME}";;

    *)
        IMAGE_NAME="${APPICON_PATH}";;
esac

BASE=`basename "$IMAGE_NAME"`

if [ ! -d "${PROJECT_DIR}/build" ]; then
  mkdir ${PROJECT_DIR}/build
fi

TMP_PATH=${PROJECT_DIR}/build

move_if_different(){
  if [ -e "$2" ]
  then
    #Compare the files at the paths given
    compare -identify -metric MAE "$1" "$2" "$TMP_PATH/null"

    RETVAL=$?

    # If files are equal, delete first file
    [ $RETVAL -eq 0 ] && rm "$1"

    # If files are different, update second file
    [ $RETVAL -ne 0 ] && echo "Copying" && mv "$1" "$2"
  else
    mv "$1" "$2"
  fi
}

for SIZE in 20 29 40 48 50 55 57 58 60 72 76 80 87 100 114 120 144 152 167 172 180 196 1024; do
  # ensure alpha is off for itunes connect
  convert "$IMAGE_NAME" -resize $SIZEx$SIZE -alpha off "$TMP_PATH/tmp_$SIZE.png"; move_if_different "$TMP_PATH/tmp_$SIZE.png" "$APPICON_SET_PATH/$SIZE.png" &
done;

wait
