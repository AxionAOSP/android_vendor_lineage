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

# Extract size and hash of the Full ZIP
SIZE=$(stat -c%s "$FILE_PATH")
ID=$(md5sum "$FILE_PATH" | awk '{print $1}')

# Check for old baseline target-files to generate incremental OTA
TOP_DIR=$(pwd)
ARCHIVE_DIR="$TOP_DIR/ota_archive"
OLD_TARGET_FILES=$(ls "$ARCHIVE_DIR"/*target_files*.zip 2>/dev/null | head -n 1)

INCREMENTAL_FILE_PATH=""
INCREMENTAL_SIZE=0
ARCHIVED_BASELINE=""

if [ -n "$OLD_TARGET_FILES" ]; then
    NEW_TARGET_FILES="$PRODUCT_OUT/obj/PACKAGING/target_files_intermediates/lineage_${TARGET_DEVICE}-target_files.zip"
    if [ -f "$NEW_TARGET_FILES" ]; then
        OLD_VERSION_NAME=$(basename "$OLD_TARGET_FILES" -target_files)
        OLD_VERSION_NAME=$(basename "$OLD_VERSION_NAME" .zip)
        INCREMENTAL_ZIP="incremental_from_${OLD_VERSION_NAME}.zip"
        INCREMENTAL_FILE_PATH="$PRODUCT_OUT/$INCREMENTAL_ZIP"

        echo "Generating incremental OTA package..."
        "$TOP_DIR/out/host/linux-x86/bin/ota_from_target_files" \
            -i "$OLD_TARGET_FILES" \
            "$NEW_TARGET_FILES" \
            "$INCREMENTAL_FILE_PATH"

        if [ $? -eq 0 ]; then
            INCREMENTAL_SIZE=$(stat -c%s "$INCREMENTAL_FILE_PATH")
            
            # Rotate target-files baseline for future incremental builds
            rm -f "$OLD_TARGET_FILES"
            ARCHIVED_BASELINE="$ARCHIVE_DIR/${FILENAME%.zip}-target_files.zip"
            mv "$NEW_TARGET_FILES" "$ARCHIVED_BASELINE"
        else
            echo "Warning: Incremental OTA generation failed."
            INCREMENTAL_FILE_PATH=""
        fi
    else
        echo "Warning: New target-files package not found. Skipping incremental OTA."
    fi
fi

# Write updater metadata json
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
echo "Datetime    : $DATETIME"
echo -e "Full ZIP    : ${BLUE}$FILE_PATH${NC}"
echo "Size        : $(numfmt --to=iec $SIZE) ($SIZE bytes)"

if [ -n "$INCREMENTAL_FILE_PATH" ]; then
    PRINTED_BASELINE=${ARCHIVED_BASELINE#$TOP_DIR/}
    echo -e "Incremental : ${BLUE}$INCREMENTAL_FILE_PATH${NC}"
    echo "Size        : $(numfmt --to=iec $INCREMENTAL_SIZE) ($INCREMENTAL_SIZE bytes)"
    echo -e "Target-Files: ${BLUE}$PRINTED_BASELINE${NC}"
fi

echo "=========================================="

exit 0
