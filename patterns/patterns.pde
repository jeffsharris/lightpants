#include "LPD8806.h"
#include "SPI.h"

// Example to control LPD8806-based RGB LED Modules in a strip!
// NOTE: WILL NOT WORK ON TRINKET OR GEMMA due to floating-point math
/*****************************************************************************/

#if defined(USB_SERIAL) || defined(USB_SERIAL_ADAFRUIT)
// this is for teensyduino support
int dataPin = 2;
int clockPin = 1;
#else 
// these are the pins we use for the LED belt kit using
// the Leonardo pinouts
int dataPin = 16;
int clockPin = 15;
#endif

#define N_LEDS       128
#define LEG_LENGTH   32
#define N_STRIPS     4

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(N_LEDS, dataPin, clockPin);

int lights[][32] = { {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
                     {63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32},
                     {64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95},
                     {127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96} };

void setup() {
  // Start up the LED strip
  strip.begin();

  // Update the strip, to start they are all 'off'
  strip.show();
}

// function prototypes, do not remove these!
void candyCane(uint32_t c1, uint32_t c2, uint8_t len, uint8_t wait);
void colorChase(uint32_t c, uint8_t wait);
void colorWipe(uint32_t c, uint8_t wait);
void dither(uint32_t c, uint8_t wait);
void scanner(uint8_t r, uint8_t g, uint8_t b, uint8_t wait);
void spiralDown(uint32_t c, uint8_t wait);
void spiralUp(uint32_t c, uint8_t wait);
void stackDown(uint32_t c1, uint32_t c2, uint8_t wait);
void wave(uint32_t c, int cycles, uint8_t wait);
void rainbowCycle(uint8_t wait);
void rainbowCycleWave(uint8_t wait);
uint32_t Wheel(uint16_t WheelPos);

void loop() {
  stackDown(strip.Color(127, 0, 0), strip.Color(127, 127, 127), 5); // red stacking on white
  stackDown(strip.Color(127, 127, 0), strip.Color(127, 0, 0), 5); // yellow stacking on red 
  stackDown(strip.Color(0, 127, 0), strip.Color(127, 127, 0), 5); // green stacking on yellow
  stackDown(strip.Color(0, 127, 127), strip.Color(0, 127, 0), 5); // cyan stacking on green
  stackDown(strip.Color(0, 0, 127), strip.Color(0, 127, 127), 5); // blue stacking on cyan
  stackDown(strip.Color(127, 0, 127), strip.Color(0, 0, 127), 5); // magenta stacking on blue
  stackDown(strip.Color(127, 127, 127), strip.Color(127, 0, 127), 5); // white stacking on magenta  
  
  rainbowCycleWave(0);
  
  candyCane(strip.Color(127,0,0), strip.Color(127, 127, 127), 3, 7, 100); // red + white
  candyCane(strip.Color(127,127,0), strip.Color(127, 0, 0), 3, 7, 100); // yellow + red
  candyCane(strip.Color(127,127,0), strip.Color(0, 127, 0), 3, 7, 100); // yellow + green
  candyCane(strip.Color(0,127,0), strip.Color(0, 127, 127), 3, 7, 100); // green + cyan
  candyCane(strip.Color(0,127,127), strip.Color(0, 0, 127), 3, 7, 100); // cyan + blue
  candyCane(strip.Color(0,0,127), strip.Color(127, 0, 127), 3, 7, 100); // blue + magenta
 
  spiral(strip.Color(127,127,127), true, 20); // white
  spiral(strip.Color(127,0,0), false, 20);     // red
  spiral(strip.Color(127,127,0), true, 20);   // yellow
  spiral(strip.Color(0,127,0), false, 20);     // green
  spiral(strip.Color(0,127,127), true, 20);   // cyan
  spiral(strip.Color(0,0,127), false, 20);     // blue
  spiral(strip.Color(127,0,127), true, 20);   // magenta
  
    // Fill the entire strip with...
  colorWipe(strip.Color(127,0,0), 20);      // red
  colorWipe(strip.Color(0, 127,0), 20);     // green
  colorWipe(strip.Color(0,0,127), 20);      // blue
  colorWipe(strip.Color(0,0,0), 20);        // black

  // Color sparkles
  dither(strip.Color(0,127,127), 50);       // cyan, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,0,127), 50);       // magenta, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,127,0), 50);       // yellow, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  
  // Spirals
  spiral(strip.Color(127,127,127), true, 20); // white
  spiral(strip.Color(127,0,0), false, 20);     // red
  spiral(strip.Color(127,127,0), true, 20);   // yellow
  spiral(strip.Color(0,127,0), false, 20);     // green
  spiral(strip.Color(0,127,127), true, 20);   // cyan
  spiral(strip.Color(0,0,127), false, 20);     // blue
  spiral(strip.Color(127,0,127), true, 20);   // magenta

  // Back-and-forth lights
  scanner(127,0,0, 30);        // red, slow
  scanner(0,0,127, 15);        // blue, fast

  // Wavy ripple effects
  wave(strip.Color(127,0,0), 4, 20);        // candy cane
  wave(strip.Color(0,0,100), 2, 40);        // icy

  // make a pretty rainbow cycle!
  rainbowCycle(0);  // make it go through the cycle fairly fast
  
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
  }
  
}
void test() {
  // Send a simple pixel chase in...
  colorChase(strip.Color(127,127,127), 20); // white
  colorChase(strip.Color(127,0,0), 20);     // red
  colorChase(strip.Color(127,127,0), 20);   // yellow
  colorChase(strip.Color(0,127,0), 20);     // green
  colorChase(strip.Color(0,127,127), 20);   // cyan
  colorChase(strip.Color(0,0,127), 20);     // blue
  colorChase(strip.Color(127,0,127), 20);   // magenta

  // Fill the entire strip with...
  colorWipe(strip.Color(127,0,0), 20);      // red
  colorWipe(strip.Color(0, 127,0), 20);     // green
  colorWipe(strip.Color(0,0,127), 20);      // blue
  colorWipe(strip.Color(0,0,0), 20);        // black

  // Color sparkles
  dither(strip.Color(0,127,127), 50);       // cyan, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,0,127), 50);       // magenta, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  dither(strip.Color(127,127,0), 50);       // yellow, slow
  dither(strip.Color(0,0,0), 15);           // black, fast
  
  // Spirals
  spiral(strip.Color(127,127,127), true, 20); // white
  spiral(strip.Color(127,0,0), false, 20);     // red
  spiral(strip.Color(127,127,0), true, 20);   // yellow
  spiral(strip.Color(0,127,0), false, 20);     // green
  spiral(strip.Color(0,127,127), true, 20);   // cyan
  spiral(strip.Color(0,0,127), false, 20);     // blue
  spiral(strip.Color(127,0,127), true, 20);   // magenta

  // Back-and-forth lights
  scanner(127,0,0, 30);        // red, slow
  scanner(0,0,127, 15);        // blue, fast

  // Wavy ripple effects
  wave(strip.Color(127,0,0), 4, 20);        // candy cane
  wave(strip.Color(0,0,100), 2, 40);        // icy

  // make a pretty rainbow cycle!
  rainbowCycle(0);  // make it go through the cycle fairly fast

  // Clear strip data before start of next effect
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
  }
}

// Cycle through the color wheel, equally spaced around the belt
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j=0; j < 384 * 5; j++) {     // 5 cycles of all 384 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color
      // wheel (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel(((i * 384 / strip.numPixels()) + j) % 384));
    }
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Cycle through the color wheel, going down all four strands simultaneously
void rainbowCycleWave(uint8_t wait) {
  uint16_t i, j;

  for (j=0; j < 384 * 5; j++) {     // 5 cycles of all 384 colors in the wheel
    for (i=0; i < LEG_LENGTH; i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color
      // wheel (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      for (int k = 0; k < N_STRIPS; k++) {
        strip.setPixelColor(lights[k][i], Wheel(((i * 384 / LEG_LENGTH) + j) % 384));
      }
    }
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Create a candy cane pattern going down each strip
void candyCane(uint32_t c1, uint32_t c2, uint8_t len, uint8_t space, uint8_t wait) {
  uint32_t pixelColor;
  
  for (int i = 0; i < LEG_LENGTH; i++) {
    int location = 0;
    while (location < LEG_LENGTH) {
      for (int j = 0; j < len; j++, location++) {
        for (int k = 0; k < N_STRIPS; k++) {
          strip.setPixelColor(lights[k][(i + location) % LEG_LENGTH], c1);
        }
        
      }
      for (int j = 0; j < space; j++, location++) {
        for (int k = 0; k < N_STRIPS; k++) {
          strip.setPixelColor(lights[k][(i + location) % LEG_LENGTH], c2);
        }
      }
    }
    strip.show();
    delay(wait);
  } 
}
      

void spiral(uint32_t c, boolean downDirection, uint8_t wait) {
  uint16_t j;
  
  if (downDirection) {  
    for (int i = 0; i < LEG_LENGTH; i++) {
      for (int j = 0; j < N_STRIPS; j++) {
        strip.setPixelColor(lights[j][i], c);
      }
      strip.show();
      delay(wait);
    }
  } else {
    for (int i = 0; i < LEG_LENGTH; i++) {
      for (int j = 0; j < N_STRIPS; j++) {
        strip.setPixelColor(lights[j][LEG_LENGTH - 1 - i], c);
      }
      strip.show();
      delay(wait);
    }
  }       
}

// Create a stack of colors that starts from the top and builds at the bottom
void stackDown(uint32_t c1, uint32_t c2, uint8_t wait) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c2);
  }
  for (int max = LEG_LENGTH; max > 0; max--) {
    for (int j = 0; j < N_STRIPS; j++) {
      strip.setPixelColor(lights[j][0], c1); // Set the first row to the color
    }
    strip.show();
    delay(wait);
    for (int i = 1; i < max; i++) { // Move the colored row down
      for (int j = 0; j < N_STRIPS; j++) {
        strip.setPixelColor(lights[j][i], c1); // Move the row down
        strip.setPixelColor(lights[j][i-1], c2); // Clear the previous row
      }
      strip.show();
      delay(wait);
    }
  }
}



// fill the dots one after the other with said color
// good for testing purposes
void colorWipe(uint32_t c, uint8_t wait) {
  int i;

  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      strip.show();
      delay(wait);
  }
}

// Chase a dot down the strip
// good for testing purposes
void colorChase(uint32_t c, uint8_t wait) {
  int i;

  for (i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);  // turn all pixels off
  }

  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c); // set one pixel
      strip.show();              // refresh strip display
      delay(wait);               // hold image for a moment
      strip.setPixelColor(i, 0); // erase pixel (but don't refresh yet)
  }
  strip.show(); // for last erased pixel
}

// An "ordered dither" fills every pixel in a sequence that looks
// sparkly and almost random, but actually follows a specific order.
void dither(uint32_t c, uint8_t wait) {

  // Determine highest bit needed to represent pixel index
  int hiBit = 0;
  int n = strip.numPixels() - 1;
  for(int bit=1; bit < 0x8000; bit <<= 1) {
    if(n & bit) hiBit = bit;
  }

  int bit, reverse;
  for(int i=0; i<(hiBit << 1); i++) {
    // Reverse the bits in i to create ordered dither:
    reverse = 0;
    for(bit=1; bit <= hiBit; bit <<= 1) {
      reverse <<= 1;
      if(i & bit) reverse |= 1;
    }
    strip.setPixelColor(reverse, c);
    strip.show();
    delay(wait);
  }
  delay(250); // Hold image for 1/4 sec
}

// "Larson scanner" = Cylon/KITT bouncing light effect
void scanner(uint8_t r, uint8_t g, uint8_t b, uint8_t wait) {
  int i, j, pos, dir;

  pos = 0;
  dir = 1;

  for(i=0; i<((strip.numPixels()-1) * 8); i++) {
    // Draw 5 pixels centered on pos.  setPixelColor() will clip
    // any pixels off the ends of the strip, no worries there.
    // we'll make the colors dimmer at the edges for a nice pulse
    // look
    strip.setPixelColor(pos - 2, strip.Color(r/4, g/4, b/4));
    strip.setPixelColor(pos - 1, strip.Color(r/2, g/2, b/2));
    strip.setPixelColor(pos, strip.Color(r, g, b));
    strip.setPixelColor(pos + 1, strip.Color(r/2, g/2, b/2));
    strip.setPixelColor(pos + 2, strip.Color(r/4, g/4, b/4));

    strip.show();
    delay(wait);
    // If we wanted to be sneaky we could erase just the tail end
    // pixel, but it's much easier just to erase the whole thing
    // and draw a new one next time.
    for(j=-2; j<= 2; j++) 
        strip.setPixelColor(pos+j, strip.Color(0,0,0));
    // Bounce off ends of strip
    pos += dir;
    if(pos < 0) {
      pos = 1;
      dir = -dir;
    } else if(pos >= strip.numPixels()) {
      pos = strip.numPixels() - 2;
      dir = -dir;
    }
  }
}

// Sine wave effect
#define PI 3.14159265
void wave(uint32_t c, int cycles, uint8_t wait) {
  float y;
  byte  r, g, b, r2, g2, b2;

  // Need to decompose color into its r, g, b elements
  g = (c >> 16) & 0x7f;
  r = (c >>  8) & 0x7f;
  b =  c        & 0x7f; 

  for(int x=0; x<(strip.numPixels()*5); x++)
  {
    for(int i=0; i<strip.numPixels(); i++) {
      y = sin(PI * (float)cycles * (float)(x + i) / (float)strip.numPixels());
      if(y >= 0.0) {
        // Peaks of sine wave are white
        y  = 1.0 - y; // Translate Y to 0.0 (top) to 1.0 (center)
        r2 = 127 - (byte)((float)(127 - r) * y);
        g2 = 127 - (byte)((float)(127 - g) * y);
        b2 = 127 - (byte)((float)(127 - b) * y);
      } else {
        // Troughs of sine wave are black
        y += 1.0; // Translate Y to 0.0 (bottom) to 1.0 (center)
        r2 = (byte)((float)r * y);
        g2 = (byte)((float)g * y);
        b2 = (byte)((float)b * y);
      }
      strip.setPixelColor(i, r2, g2, b2);
    }
    strip.show();
    delay(wait);
  }
}

/* Helper functions */

//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g - b - back to r

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128; // red down
      g = WheelPos % 128;       // green up
      b = 0;                    // blue off
      break;
    case 1:
      g = 127 - WheelPos % 128; // green down
      b = WheelPos % 128;       // blue up
      r = 0;                    // red off
      break;
    case 2:
      b = 127 - WheelPos % 128; // blue down
      r = WheelPos % 128;       // red up
      g = 0;                    // green off
      break;
  }
  return(strip.Color(r,g,b));
}
