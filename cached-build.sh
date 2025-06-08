#! /bin/bash

GENERATE_PATH="$(swift build --show-bin-path)/generate"

if [ ! -f "$GENERATE_PATH" ]; then
    echo "Cached executable not found. Building it."
    swift build
else
    echo "Using cached executable."
fi

"$GENERATE_PATH"
