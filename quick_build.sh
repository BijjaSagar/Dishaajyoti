#!/bin/bash

# Quick Build Script for Dishaajyoti
# This script helps build the app with proper error handling

set -e  # Exit on error

echo "🚀 Dishaajyoti Quick Build Script"
echo "=================================="
echo ""

# Check if we're in iCloud Drive
if [[ "$PWD" == *"com~apple~CloudDocs"* ]]; then
    echo "⚠️  WARNING: Project is in iCloud Drive!"
    echo "This can cause build timeouts and errors."
    echo ""
    echo "Recommended: Move project to local directory"
    echo "Run: mkdir -p ~/Projects && mv ~/Library/Mobile\\ Documents/com~apple~CloudDocs/Dishaajyoti ~/Projects/"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Parse command line arguments
BUILD_TYPE="debug"
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help)
            echo "Usage: ./quick_build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --release    Build release APK (default: debug)"
            echo "  --clean      Clean before building"
            echo "  --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./quick_build.sh                    # Debug build"
            echo "  ./quick_build.sh --release          # Release build"
            echo "  ./quick_build.sh --clean --release  # Clean + release build"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run './quick_build.sh --help' for usage"
            exit 1
            ;;
    esac
done

echo "📋 Build Configuration:"
echo "  Type: $BUILD_TYPE"
echo "  Clean: $CLEAN"
echo ""

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo "🧹 Cleaning project..."
    flutter clean
    rm -rf build/
    rm -rf android/build/
    rm -rf android/app/build/
    echo "✅ Clean complete"
    echo ""
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo "✅ Dependencies updated"
echo ""

# Build
echo "🔨 Building $BUILD_TYPE APK..."
if [ "$BUILD_TYPE" = "release" ]; then
    flutter build apk --release
else
    flutter build apk --debug
fi

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    if [ "$BUILD_TYPE" = "release" ]; then
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    else
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    fi
    
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        echo "📱 APK Location: $APK_PATH"
        echo "📊 APK Size: $APK_SIZE"
        echo ""
        echo "To install on device:"
        echo "  adb install $APK_PATH"
    fi
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "Common fixes:"
    echo "  1. Move project out of iCloud Drive"
    echo "  2. Run: flutter clean && flutter pub get"
    echo "  3. Check BUILD_FIX.md for detailed solutions"
    exit 1
fi
