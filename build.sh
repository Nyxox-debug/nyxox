#!/bin/bash
rm -rf docs
hugo build --destination docs/
echo "✓ Build complete! Output in docs/"
