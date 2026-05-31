#!/bin/bash
# Quick verification script for README standardization system

set -e

echo "🔧 README Standardization System - Verification Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check dependencies
echo "📦 Step 1: Installing dependencies..."
cd tools/readme_sync
flutter pub get || dart pub get
cd ../..
echo "✓ Dependencies installed"
echo ""

# Validate markers
echo "🔍 Step 2: Validating all README markers..."
dart run tools/readme_sync/readme_sync.dart --validate
echo ""

# Show what would change (dry-run on single package)
echo "🔬 Step 3: Testing dry-run on timer_button package..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart run tools/readme_sync/readme_sync.dart --dry-run --package timer_button
echo ""

# Offer to run full dry-run
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Validation complete!"
echo ""
echo "📋 Next steps you can try:"
echo "   1. Full dry-run:    dart run tools/readme_sync/readme_sync.dart --dry-run"
echo "   2. Sync one package: dart run tools/readme_sync/readme_sync.dart --package timer_button"
echo "   3. Sync all:        melos sync:readme"
echo ""
echo "📚 Documentation: tools/readme_sync/README.md"
echo ""
