#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <TARGET_DEVICE> <PRODUCT_OUT> <FILENAME>"
    exit 1
fi

TARGET_DEVICE=$1
PRODUCT_OUT=$2
LINEAGE_ZIP=$3
FILENAME="axion-$LINEAGE_ZIP"

if [[ "$FILENAME" =~ ^axion-([0-9]+(\.[0-9]+)*)-([[:alnum:]_]+)-[0-9]+-(COMMUNITY|OFFICIAL|UNOFFICIAL)-(GMS|PICO|CORE|VANILLA)-.+\.zip$ ]]; then
    VERSION="${BASH_REMATCH[1]}"
    ROMTYPE="${BASH_REMATCH[4]}"
    BUILD_FLAVOR="${BASH_REMATCH[5]}"
else
    echo "Error: Unable to parse filename: $FILENAME"
    exit 1
fi

case "$BUILD_FLAVOR" in
    GMS|PICO|CORE) FLAVOR="GMS" ;;
    VANILLA) FLAVOR="VANILLA" ;;
    *)
        echo "Error: Unable to map build flavor from filename: $BUILD_FLAVOR"
        exit 1
        ;;
esac

FILE_PATH="$PRODUCT_OUT/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

BUILDPROP_PATH="$PRODUCT_OUT/system/build.prop"
DATETIME=$(grep "ro.build.date.utc" "$BUILDPROP_PATH" | cut -d'=' -f2 | tr -d '\r\n')

if [ -z "$DATETIME" ]; then
    echo "Error: Could not extract timestamp from build.prop"
    exit 1
fi

SIZE=$(stat -c%s "$FILE_PATH")
ID=$(md5sum "$FILE_PATH" | awk '{print $1}')

JSON_DIR="$PRODUCT_OUT/$FLAVOR"
if [ ! -d "$JSON_DIR" ]; then
    mkdir -p "$JSON_DIR"
fi
JSON_FILE="$JSON_DIR/${TARGET_DEVICE}.json"

cat > "$JSON_FILE" <<EOF
{
    "response": [
        {
            "datetime": $DATETIME,
            "filename": "$FILENAME",
            "id": "$ID",
            "romtype": "$ROMTYPE",
            "size": $SIZE,
            "url": "https://cdn.axionos.org/$TARGET_DEVICE/$FILENAME",
            "version": "$VERSION"
        }
    ]
}
EOF

echo "JSON saved to: $JSON_FILE"
cat "$JSON_FILE"

echo "=========================================="
echo -e "         ${RED}Welcome to the Axion${NC}             "
echo "=========================================="
echo -e "        ${GREEN}BUILD COMPLETED SUCCESSFULLY${NC}      "
echo "------------------------------------------"
echo "Datetime : $DATETIME"
echo "Size     : $(numfmt --to=iec $SIZE) ($SIZE bytes)"
echo -e "Output   : ${BLUE}$FILE_PATH${NC}"
echo "=========================================="

exit 0
