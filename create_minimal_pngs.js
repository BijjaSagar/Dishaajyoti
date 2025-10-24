#!/usr/bin/env node

/**
 * Creates minimal valid PNG files as placeholders
 * These are simple solid color PNGs that can be replaced with proper designs
 */

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

function createPNG(width, height, r, g, b, a = 255) {
  // PNG signature
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  
  // IHDR chunk
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr.writeUInt8(8, 8); // bit depth
  ihdr.writeUInt8(6, 9); // color type (RGBA)
  ihdr.writeUInt8(0, 10); // compression
  ihdr.writeUInt8(0, 11); // filter
  ihdr.writeUInt8(0, 12); // interlace
  
  const ihdrChunk = createChunk('IHDR', ihdr);
  
  // Create image data
  const bytesPerPixel = 4; // RGBA
  const imageData = Buffer.alloc(height * (1 + width * bytesPerPixel));
  
  for (let y = 0; y < height; y++) {
    const rowStart = y * (1 + width * bytesPerPixel);
    imageData[rowStart] = 0; // filter type: none
    
    for (let x = 0; x < width; x++) {
      const pixelStart = rowStart + 1 + x * bytesPerPixel;
      imageData[pixelStart] = r;
      imageData[pixelStart + 1] = g;
      imageData[pixelStart + 2] = b;
      imageData[pixelStart + 3] = a;
    }
  }
  
  // Compress image data
  const compressedData = zlib.deflateSync(imageData, { level: 9 });
  const idatChunk = createChunk('IDAT', compressedData);
  
  // IEND chunk
  const iendChunk = createChunk('IEND', Buffer.alloc(0));
  
  // Combine all chunks
  return Buffer.concat([signature, ihdrChunk, idatChunk, iendChunk]);
}

function createChunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  
  const typeBuffer = Buffer.from(type, 'ascii');
  const crc = calculateCRC(Buffer.concat([typeBuffer, data]));
  const crcBuffer = Buffer.alloc(4);
  crcBuffer.writeUInt32BE(crc, 0);
  
  return Buffer.concat([length, typeBuffer, data, crcBuffer]);
}

function calculateCRC(buffer) {
  let crc = 0xFFFFFFFF;
  
  for (let i = 0; i < buffer.length; i++) {
    crc ^= buffer[i];
    for (let j = 0; j < 8; j++) {
      if (crc & 1) {
        crc = (crc >>> 1) ^ 0xEDB88320;
      } else {
        crc = crc >>> 1;
      }
    }
  }
  
  return (crc ^ 0xFFFFFFFF) >>> 0;
}

// Create directories
const iconsDir = path.join(__dirname, 'assets', 'icons');
const imagesDir = path.join(__dirname, 'assets', 'images');

if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

console.log('Creating minimal PNG placeholders...\n');

// Create app icon (1024x1024) - Blue color
const appIcon = createPNG(1024, 1024, 0, 102, 204, 255);
fs.writeFileSync(path.join(iconsDir, 'app_icon.png'), appIcon);
console.log('✓ Created app_icon.png (1024x1024) - Blue placeholder');

// Create adaptive icon foreground (432x432) - White with transparency
const foreground = createPNG(432, 432, 255, 255, 255, 255);
fs.writeFileSync(path.join(iconsDir, 'app_icon_foreground.png'), foreground);
console.log('✓ Created app_icon_foreground.png (432x432) - White placeholder');

// Create splash logo (512x512) - White with slight transparency
const splash = createPNG(512, 512, 255, 255, 255, 230);
fs.writeFileSync(path.join(imagesDir, 'splash_logo.png'), splash);
console.log('✓ Created splash_logo.png (512x512) - White placeholder');

console.log('\n✅ Minimal PNG placeholders created successfully!\n');
console.log('⚠️  IMPORTANT: These are solid color placeholders.');
console.log('   Replace them with proper designs before production.\n');
console.log('Next steps:');
console.log('  1. Replace placeholders with professional designs');
console.log('  2. Run: flutter pub get');
console.log('  3. Run: dart run flutter_launcher_icons');
console.log('  4. Run: dart run flutter_native_splash:create');
console.log('\nSee ASSETS_SETUP.md for detailed instructions.');
