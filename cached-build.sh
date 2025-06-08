#! /bin/bash

EXECUTABLE="./generate"

if [ ! -f "$EXECUTABLE" ]; then
    echo "Cached executable not found. Building it."
    swift build
    cp "$(swift build --show-bin-path)/generate" "$EXECUTABLE"
else
    echo "Using cached executable."
fi

"$EXECUTABLE"
