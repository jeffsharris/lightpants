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
#define N_COLORS     7

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(N_LEDS, dataPin, clockPin);

int lights[][32] = { {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
                     {63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32},
                     {64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95},
                     {127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96} };
                  
uint32_t colors[] = { strip.Color(127, 0, 0), strip.Color(127, 127, 0), strip.Color(0, 127, 0), strip.Color(0, 127, 127), strip.Color(0, 0, 127), strip.Color(127, 0, 127), strip.Color(127, 127, 127) };

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
void merge(uint32_t c1, uint32_t c2, boolean fromEdges, uint8_t wait);
void rainbowDither(uint8_t wait);
void rainbowCycle(uint8_t wait);
void rainbowCycleWave(uint8_t wait);
void rainbowJump(uint8_t wait, boolean downDirection);
void scanner(uint8_t r, uint8_t g, uint8_t b, uint8_t wait);
void spiralDown(uint32_t c, uint8_t wait);
void spiralUp(uint32_t c, uint8_t wait);
void stack(uint32_t c1, uint32_t c2, boolean downDirection, uint8_t wait);
void wave(uint32_t c, int cycles, uint8_t wait);
uint32_t Wheel(uint16_t WheelPos);

void loop() {

rainbowCycleWave(0);
  
for (int j = 0; j < 10; j++) {
  for (int i = 1; i <= N_COLORS; i++ ) {
    merge(colors[i % N_COLORS], colors[(i - 1) % N_COLORS], (j + i) % 2, 20);
  }
}
  
  
rainbowJump(20, true);
rainbowJump(20, false);




for (int i = 0; i < N_COLORS; i++) {
  stack(colors[i], colors[(i - 1) % N_COLORS], i % 2, 5);
}

for (int i = 0; i < N_COLORS; i++) {
  candyCane(colors[i], colors[(i - 1) % N_COLORS], 3, 7, 100);
}

// Color sparkles
for (int i = 0; i < N_COLORS; i++) {
  dither(colors[i], random(50));
}

for (int i = 0; i < N_COLORS; i++) {
  spiral(colors[i], i % 2, 20);
}  
 
// Fill the entire strip with...
for (int i = 0; i < N_COLORS; i++) {
  colorWipe(colors[i], 20);
}

for (int i = 0; i < 5; i++) {
  rainbowDither(10);
  dither(strip.Color(0, 0, 0), 10);
}
  
scanner(127,0,0, 30);        // red, slow
scanner(0,0,127, 15);        // blue, fast

//Wavy ripple effects
wave(strip.Color(127,0,0), 4, 20);        // candy cane
wave(strip.Color(0,0,100), 2, 40);        // icy

// make a pretty rainbow cycle!
rainbowCycle(0);  // make it go through the cycle fairly fast
  
  for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
  }
  
}
void test() {
  for (int i = 0; i < N_STRIPS; i++) {
  strip.setPixelColor(i * 32 + 0, strip.Color(127, 127, 127));
  strip.setPixelColor(i * 32 + 1, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 2, strip.Color(127, 127, 0));
  strip.setPixelColor(i * 32 + 3, strip.Color(0, 127, 0));
  strip.setPixelColor(i * 32 + 4, strip.Color(0, 127, 127));
  strip.setPixelColor(i * 32 + 5, strip.Color(0, 0, 127));
  strip.setPixelColor(i * 32 + 6, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 7, strip.Color(127, 0, 127));
  strip.setPixelColor(i * 32 + 8, strip.Color(45, 60, 127));
  strip.setPixelColor(i * 32 + 9, strip.Color(0, 0, 0));
  strip.setPixelColor(i * 32 + 10, strip.Color(127, 127, 127));
  strip.setPixelColor(i * 32 + 11, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 12, strip.Color(127, 127, 0));
  strip.setPixelColor(i * 32 + 13, strip.Color(0, 127, 0));
  strip.setPixelColor(i * 32 + 14, strip.Color(0, 127, 127));
  strip.setPixelColor(i * 32 + 15, strip.Color(0, 0, 127));
  strip.setPixelColor(i * 32 + 16, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 17, strip.Color(127, 0, 127));
  strip.setPixelColor(i * 32 + 18, strip.Color(45, 45, 45));
  strip.setPixelColor(i * 32 + 19, strip.Color(0, 0, 0));
  strip.setPixelColor(i * 32 + 20, strip.Color(127, 127, 127));
  strip.setPixelColor(i * 32 + 21, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 22, strip.Color(127, 127, 0));
  strip.setPixelColor(i * 32 + 23, strip.Color(0, 127, 0));
  strip.setPixelColor(i * 32 + 24, strip.Color(0, 127, 127));
  strip.setPixelColor(i * 32 + 25, strip.Color(0, 0, 127));
  strip.setPixelColor(i * 32 + 26, strip.Color(127, 0, 0));
  strip.setPixelColor(i * 32 + 27, strip.Color(127, 0, 127));
  strip.setPixelColor(i * 32 + 28, strip.Color(45, 45, 45));
  strip.setPixelColor(i * 32 + 29, strip.Color(0, 0, 0));
  strip.setPixelColor(i * 32 + 30, strip.Color(127, 127, 127));
  strip.setPixelColor(i * 32 + 31, strip.Color(127, 0, 0));
  }
  strip.show(); 
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

// Lights merge together either from top and bottom or apart from middle
void merge(uint32_t c1, uint32_t c2, boolean fromEdges, uint8_t wait) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c2);
  }
  strip.show();
  delay(wait);  
  if (fromEdges) {
    for (int i = 0, j = LEG_LENGTH - 1; i < j; i++, j--) {
      for (int k = 0; k < N_STRIPS; k++) {
        strip.setPixelColor(lights[k][i], c1);
        strip.setPixelColor(lights[k][j], c1);
      }
    strip.show();
    delay(wait); 
    }
  } else {
    for (int i = (LEG_LENGTH / 2) - 1, j = LEG_LENGTH / 2; i >=0; i--, j++) {
      for (int k = 0; k < N_STRIPS; k++) {
        strip.setPixelColor(lights[k][i], c1);
        strip.setPixelColor(lights[k][j], c1);
      }
      strip.show();
      delay(wait);       
    }
  }  
}

// An "ordered dither" fills every pixel in a sequence that looks
// sparkly and almost random, but actually follows a specific order.
// This pattern uses a random assortment of colors.
void rainbowDither(uint8_t wait) {

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
    strip.setPixelColor(reverse, colors[random(N_COLORS)]);
    strip.show();
    delay(wait);
  }
  delay(250); // Hold image for 1/4 sec
}

// Create a rainbow pattern that moves from up/down the pants and jumps from one end to another
void rainbowJump(uint8_t wait, boolean downDirection) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, strip.Color(127, 127, 127));
  }
  if (downDirection) {
    for (int i = 0; i < 315 ; i++) {
      for (int j = 0; j < N_COLORS - 1; j++) { // (N_COLORS-1) to avoid using the white final color
        for (int k = 0; k < N_STRIPS; k++) {
          strip.setPixelColor(lights[k][(i+j) % LEG_LENGTH], colors[j]);
        }
      }
      for (int k = 0; k < N_STRIPS; k++) {
        strip.setPixelColor(lights[k][(i - 1) % LEG_LENGTH], strip.Color(127, 127, 127));
      }  
      strip.show();
      delay(wait);
    }
  } else {
    for (int i = 314; i >= 0; i--) {
      for (int j = 0; j < N_COLORS - 1; j++) {
        for (int k = 0; k < N_STRIPS; k++) {
          strip.setPixelColor(lights[k][(i+j) % LEG_LENGTH], colors[j]);
        }
      }
      for (int k = 0; k < N_STRIPS; k++) {
        strip.setPixelColor(lights[k][(i + N_COLORS - 1) % LEG_LENGTH], strip.Color(127, 127, 127));
      }
      strip.show();
      delay(wait);
    }
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

// Spiral pattern in either an up or down direction
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

// Create a stack of colors in either up or down direction
void stack(uint32_t c1, uint32_t c2, boolean downDirection, uint8_t wait) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c2);
  }
  if (downDirection) {
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
  } else {
    for (int min = 0; min < LEG_LENGTH; min++) {
      for (int j = 0; j < N_STRIPS; j++) {
        strip.setPixelColor(lights[j][LEG_LENGTH - 1], c1); // Set the last row to the color
      }
      strip.show();
      delay(wait);
      for (int i = LEG_LENGTH - 2; i >= min; i--) { // Move the colored row up
        for (int j = 0; j < N_STRIPS; j++) {
          strip.setPixelColor(lights[j][i], c1); // Move the row down
          strip.setPixelColor(lights[j][i+1], c2); // Clear the previous row
        }
        strip.show();
        delay(wait);
      }
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
