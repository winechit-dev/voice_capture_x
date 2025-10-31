#!/bin/bash

echo "🔧 Voice Capture X - Permission Fix Test Script"
echo "================================================"
echo ""

# Change to project directory
cd "$(dirname "$0")"

echo "📍 Working directory: $(pwd)"
echo ""

# Step 1: Clean
echo "🧹 Step 1/5: Cleaning Flutter project..."
flutter clean

echo ""
echo "🧹 Step 2/5: Cleaning iOS pods..."
cd ios
rm -rf Pods Podfile.lock
cd ..

echo ""
echo "📦 Step 3/5: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "📦 Step 4/5: Installing iOS pods..."
cd ios
pod install
cd ..

echo ""
echo "🚀 Step 5/5: Running app..."
echo ""
echo "⚠️  IMPORTANT: Test on a PHYSICAL iOS DEVICE for accurate results!"
echo "    Simulators have limited microphone support."
echo ""
echo "👀 Watch for these debug logs in console:"
echo "   ✅ Microphone permission granted"
echo "   ✅ Speech-to-text initialized successfully"
echo ""
echo "🎯 When permission dialogs appear:"
echo "   1. Tap 'Allow' for microphone access"
echo "   2. Tap 'OK' for speech recognition"
echo ""
echo "Starting app in 3 seconds..."
sleep 3

flutter run --flavor development --target lib/main_development.dart

echo ""
echo "✅ Test complete!"
