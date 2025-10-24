#!/usr/bin/env node

/**
 * Script to generate placeholder app icon and splash screen assets
 * Requires: npm install canvas (or use the simpler base64 approach below)
 * 
 * For production, replace these with professionally designed assets.
 */

const fs = require('fs');
const path = require('path');

// Create directories
const iconsDir = path.join(__dirname, 'assets', 'icons');
const imagesDir = path.join(__dirname, 'assets', 'images');

if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

console.log('DishaAjyoti Asset Generator');
console.log('============================\n');

// Check if canvas is available
let Canvas;
try {
  Canvas = require('canvas');
  generateWithCanvas();
} catch (e) {
  console.log('Canvas module not found. Using placeholder approach...\n');
  generatePlaceholders();
}

function generateWithCanvas() {
  const { createCanvas } = Canvas;
  
  // Generate app icon (1024x1024)
  console.log('Generating app_icon.png (1024x1024)...');
  const iconCanvas = createCanvas(1024, 1024);
  const iconCtx = iconCanvas.getContext('2d');
  
  // Gradient background
  const gradient = iconCtx.createLinearGradient(0, 0, 1024, 1024);
  gradient.addColorStop(0, '#0066CC');
  gradient.addColorStop(1, '#FF6B35');
  iconCtx.fillStyle = gradient;
  iconCtx.fillRect(0, 0, 1024, 1024);
  
  // White circle
  iconCtx.fillStyle = 'rgba(255, 255, 255, 0.2)';
  iconCtx.beginPath();
  iconCtx.arc(512, 512, 358, 0, Math.PI * 2);
  iconCtx.fill();
  
  // DA text
  iconCtx.fillStyle = '#FFFFFF';
  iconCtx.font = 'bold 360px Arial';
  iconCtx.textAlign = 'center';
  iconCtx.textBaseline = 'middle';
  iconCtx.fillText('DA', 512, 512);
  
  const iconBuffer = iconCanvas.toBuffer('image/png');
  fs.writeFileSync(path.join(iconsDir, 'app_icon.png'), iconBuffer);
  console.log('✓ Generated app_icon.png');
  
  // Generate adaptive icon foreground (432x432)
  console.log('Generating app_icon_foreground.png (432x432)...');
  const foregroundCanvas = createCanvas(432, 432);
  const foregroundCtx = foregroundCanvas.getContext('2d');
  
  // White circle
  foregroundCtx.fillStyle = '#FFFFFF';
  foregroundCtx.beginPath();
  foregroundCtx.arc(216, 216, 151, 0, Math.PI * 2);
  foregroundCtx.fill();
  
  // DA text in blue
  foregroundCtx.fillStyle = '#0066CC';
  foregroundCtx.font = 'bold 150px Arial';
  foregroundCtx.textAlign = 'center';
  foregroundCtx.textBaseline = 'middle';
  foregroundCtx.fillText('DA', 216, 216);
  
  const foregroundBuffer = foregroundCanvas.toBuffer('image/png');
  fs.writeFileSync(path.join(iconsDir, 'app_icon_foreground.png'), foregroundBuffer);
  console.log('✓ Generated app_icon_foreground.png');
  
  // Generate splash logo (512x512)
  console.log('Generating splash_logo.png (512x512)...');
  const splashCanvas = createCanvas(512, 512);
  const splashCtx = splashCanvas.getContext('2d');
  
  // White circle
  splashCtx.fillStyle = 'rgba(255, 255, 255, 0.9)';
  splashCtx.beginPath();
  splashCtx.arc(256, 256, 205, 0, Math.PI * 2);
  splashCtx.fill();
  
  // DA text in blue
  splashCtx.fillStyle = '#0066CC';
  splashCtx.font = 'bold 205px Arial';
  splashCtx.textAlign = 'center';
  splashCtx.textBaseline = 'middle';
  splashCtx.fillText('DA', 256, 256);
  
  const splashBuffer = splashCanvas.toBuffer('image/png');
  fs.writeFileSync(path.join(imagesDir, 'splash_logo.png'), splashBuffer);
  console.log('✓ Generated splash_logo.png');
  
  printNextSteps();
}

function generatePlaceholders() {
  console.log('Creating placeholder asset files...\n');
  console.log('⚠️  Note: These are minimal placeholders.');
  console.log('   For production, create proper assets using:');
  console.log('   - Design tools (Figma, Photoshop, Illustrator)');
  console.log('   - Or install canvas: npm install canvas\n');
  
  // Create simple SVG placeholders that can be converted
  const appIconSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#0066CC;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FF6B35;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#grad)"/>
  <circle cx="512" cy="512" r="358" fill="rgba(255,255,255,0.2)"/>
  <text x="512" y="580" font-family="Arial" font-size="360" font-weight="bold" 
        fill="white" text-anchor="middle">DA</text>
</svg>`;
  
  const foregroundSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="432" height="432" xmlns="http://www.w3.org/2000/svg">
  <circle cx="216" cy="216" r="151" fill="white"/>
  <text x="216" y="250" font-family="Arial" font-size="150" font-weight="bold" 
        fill="#0066CC" text-anchor="middle">DA</text>
</svg>`;
  
  const splashSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <circle cx="256" cy="256" r="205" fill="rgba(255,255,255,0.9)"/>
  <text x="256" y="300" font-family="Arial" font-size="205" font-weight="bold" 
        fill="#0066CC" text-anchor="middle">DA</text>
</svg>`;
  
  // Save SVG files
  fs.writeFileSync(path.join(iconsDir, 'app_icon.svg'), appIconSvg);
  fs.writeFileSync(path.join(iconsDir, 'app_icon_foreground.svg'), foregroundSvg);
  fs.writeFileSync(path.join(imagesDir, 'splash_logo.svg'), splashSvg);
  
  console.log('✓ Created app_icon.svg');
  console.log('✓ Created app_icon_foreground.svg');
  console.log('✓ Created splash_logo.svg\n');
  
  console.log('To convert SVG to PNG, you can:');
  console.log('1. Install canvas: npm install canvas');
  console.log('   Then run: node generate_assets.js');
  console.log('2. Use online converter: https://cloudconvert.com/svg-to-png');
  console.log('3. Use ImageMagick: convert -density 300 file.svg file.png');
  console.log('4. Use Inkscape: inkscape --export-png=file.png file.svg\n');
  
  console.log('Or create professional assets using design tools and place them at:');
  console.log('  - assets/icons/app_icon.png (1024x1024)');
  console.log('  - assets/icons/app_icon_foreground.png (432x432)');
  console.log('  - assets/images/splash_logo.png (512x512)\n');
}

function printNextSteps() {
  console.log('\n✅ Assets generated successfully!\n');
  console.log('Next steps:');
  console.log('  1. Review the generated assets');
  console.log('  2. Replace with professional designs if needed');
  console.log('  3. Run: flutter pub get');
  console.log('  4. Run: dart run flutter_launcher_icons');
  console.log('  5. Run: dart run flutter_native_splash:create');
  console.log('\nSee ASSETS_SETUP.md for more details.');
}
