#!/bin/bash
rm -rf docs
hugo --minify --destination docs
echo "✓ Build complete! Output in docs/"
