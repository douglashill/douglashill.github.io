#! /bin/bash

# This makes swift-markdown look for swift-cmark locally to avoid going to the network.
export SWIFTCI_USE_LOCAL_DEPS="1"
swift run
