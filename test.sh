#!/bin/bash

# Ensure we are in a Swift package directory
if [ ! -f "Package.swift" ]; then
  echo "Error: No Package.swift found in $(pwd)"
  exit 1
fi

echo "🚀 Running swift test..."
swift test "$@"
