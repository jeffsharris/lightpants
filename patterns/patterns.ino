#include "FastLED.h"

// The brightness value to use
#define BRIGHTNESS                  255

// The color order for this strip model
#define COLOR_ORDER                 GRB

#define N_LEDS 6

// Data pin that led data will be written out over
#define DATA_PIN 6

#define N_LEDS       128
#define LEG_LENGTH   32
#define LED_PER_ROW  18
#define N_ROWS       7
#define N_STRIPS     4
#define N_COLORS     7

// Create the array of LEDs
CRGB leds[N_LEDS];

int lights[][32] = { {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
                     {63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32},
                     {64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95},
                     {127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96} };
                  
CRGB colors[] = { CRGB(255, 0, 0), CRGB(255, 255, 0), CRGB(0, 255, 0), CRGB(0, 255, 255), CRGB(0, 0, 255), CRGB(255, 0, 255), CRGB(255, 255, 255) };

void setup() {
  FastLED.addLeds<WS2812B, DATA_PIN, COLOR_ORDER>(leds, N_LEDS).setCorrection( TypicalLEDStrip ).setTemperature(  UncorrectedTemperature );
  FastLED.setBrightness(  BRIGHTNESS );;
}


void loop() {
  dither(40);
  rainbowCycleWave(0);
  wave(CRGB(127,0,0), 4, 20);        // candy cane
  wave(CRGB(0,0,100), 2, 40);        // icy
  for (int j = 0; j < 10; j++) {
    for (int i = 1; i <= N_COLORS; i++ ) {
      merge(colors[i % N_COLORS], (j + i) % 2, 20);
    }
  }
  rainbowJump(20);
  stack(colors[4], 0, 1, 5);
  for (int i = 0; i < N_COLORS - 2; i++) {
    stack(colors[i], colors[(i - 1) % N_COLORS], i % 2, 5);
  }
  stack(colors[N_COLORS - 3], colors[(N_COLORS - 4) % N_COLORS], 1, 5);
  for (int i = 0; i < N_COLORS; i++) {
    candyCane(colors[i], colors[(i - 1) % N_COLORS], 3, 7, 100);
  }
  for (int i = 0; i < N_COLORS; i++) {
    spiral(colors[i], i % 2, 20);
  }  
  // Fill the entire strip with...
  for (int i = 0; i < N_COLORS; i++) {
    colorWipe(colors[i], i % 2, 20);
  }
  rainbowCycle(0);  // make it go through the cycle fairly fast
  rainbowDither(10);
}


  
// Create a candy cane pattern going down each strip
void candyCane(CRGB c1, CRGB c2, uint8_t len, uint8_t space, uint8_t wait) {
  uint32_t pixelColor;
  
  for (int i = 0; i < LEG_LENGTH; i++) {
    int location = 0;
    while (location < LEG_LENGTH) {
      for (int j = 0; j < len; j++, location++) {
        if (i < location) {
          continue;
        }
        for (int k = 0; k < N_STRIPS; k++) {
          leds[lights[k][(i + location) % LEG_LENGTH]] = c1;
        }
      }
      for (int j = 0; j < space; j++, location++) {
        if (i < location) {
          continue;
        }
        for (int k = 0; k < N_STRIPS; k++) {
          leds[lights[k][(i + location) % LEG_LENGTH]] = c2;
        }
      }
    }
    FastLED.show();      
    FastLED.delay(wait);   
  } 
}

// Chase a dot down the strip
// good for testing purposes
void colorChase(CRGB c, uint8_t wait) {
  int i;
  for (i=0; i < N_LEDS; i++) {
    leds[i] = 0;
  }
  for (i=0; i < N_LEDS; i++) {
    leds[i] = c;
    FastLED.show();
    FastLED.delay(wait);  
    leds[i] = 0; // erase pixel (but don't refresh yet)
  }
  FastLED.show(); // for last erased pixel
}

// fill the dots one after the other with said color
// good for testing purposes
void colorWipe(CRGB c, boolean startFromZero, uint8_t wait) {
  int i;
  if (startFromZero) {
    for (i=0; i < N_LEDS; i++) {
      leds[i] = c;
      FastLED.show();
      FastLED.delay(wait); 
    }
  } else {
    for (i = N_LEDS - 1; i >= 0; i--) {
      leds[i] = c;
      FastLED.show();
      FastLED.delay(wait); 
    }
  }
}

// An "ordered dither" fills every pixel in a sequence that looks
// sparkly and almost random, but actually follows a specific order.
void dither(uint8_t wait) {
  uint32_t rainbowColors[N_LEDS];  // Make the dither pattern transition into the rainbowCycleWave pattern
  for (int i=0; i < LEG_LENGTH; i++) {
      for (int k = 0; k < N_STRIPS; k++) {
        rainbowColors[lights[k][i]] = Wheel(((i * 384 / LEG_LENGTH)) % 384);
      }
    }

  // Determine highest bit needed to represent pixel index
  int hiBit = 0;
  int n = N_LEDS - 1;
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
    leds[reverse] = rainbowColors[reverse]; 
    FastLED.show();
    FastLED.delay(wait);
  }
  FastLED.delay(250); // Hold image for 1/4 sec
}

// Lights merge together either from top and bottom or apart from middle
void merge(CRGB c1, boolean fromEdges, uint8_t wait) {
  for (int i = 0; i < LEG_LENGTH / 2 - 1; i++) {
    for (int k = 0; k <= i; k++) {
      for (int m = 0; m < N_STRIPS; m++) {
        uint32_t dimmedColor = dimColor(c1, (1.0 + k) / (1.0 + i));
        if (fromEdges) {
          leds[lights[m][k]] = dimmedColor;
          leds[lights[m][LEG_LENGTH - 1 - k]] = dimmedColor;
        } else {
          leds[lights[m][LEG_LENGTH / 2 - 1 - k]] = dimmedColor;
          leds[lights[m][LEG_LENGTH / 2 + k]] = dimmedColor;
        }
      }
    }
    FastLED.show();
    FastLED.delay(wait); 
  }
}

// An "ordered dither" fills every pixel in a sequence that looks
// sparkly and almost random, but actually follows a specific order.
// This pattern uses a random assortment of colors.
void rainbowDither(uint8_t wait) {
  // Determine highest bit needed to represent pixel index
  int hiBit = 0;
  int n = N_LEDS - 1;
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
    leds[reverse] = colors[random(N_COLORS)];
    FastLED.show();
    FastLED.delay(wait);
  }
  FastLED.delay(250); // Hold image for 1/4 sec
}

// Create a rainbow pattern that moves around the pants
void rainbowJump(uint8_t wait) {
  for (int i = 0; i < N_LEDS; i++) {
    leds[i] = colors[N_COLORS - 1];
  }
  for (int i = 0, j = 314; i < 315 && j >=0; i++, j--) {
    for (int k = 0; k < N_COLORS - 1; k++) { // (N_COLORS-1) to avoid using the white final color. This could probably be cleaned up by taking advantage of the white fill color being in this array
      leds[(i+k) % N_LEDS] = colors[k];
    }
    leds[(i-1) % N_LEDS] = colors[N_COLORS - 1];
    FastLED.show();
    FastLED.delay(wait);
  }
}
// Cycle through the color wheel, equally spaced around the strip
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;

  for (j=0; j < 768 * 3; j++) {     // 5 cycles of all 768 colors in the wheel
    for (i=0; i < N_LEDS; i++) {
      // tricky math! we use each pixel as a fraction of the full 768-color
      // wheel (thats the i / N_LEDS part)
      // Then add in j which makes the colors go around per pixel
      // the % 768 is to make the wheel cycle around
      leds[i] = Wheel(((i * 768 / N_LEDS) + j) % 768);
    }
    FastLED.show();   // write all the pixels out
    FastLED.delay(wait);
  }
}

void rainbowCycleWave(uint8_t wait) {
  uint16_t i, j;
  for (j=0; j < 768 * 3; j++) {     // 5 cycles of all 768 colors in the wheel
    for (i=0; i < LEG_LENGTH; i++) {
      // tricky math! we use each pixel as a fraction of the full 768-color
      // wheel (thats the i / N_LEDS part)
      // Then add in j which makes the colors go around per pixel
      // the % 768 is to make the wheel cycle around
      for (int k = 0; k < N_STRIPS; k++) {
        leds[lights[k][i]] = Wheel(((i * 768 / LEG_LENGTH) + j) % 768);
      }
    }
    FastLED.show();   // write all the pixels out
    FastLED.delay(wait);
  }
}

// Spiral pattern in either an up or down direction
void spiral(CRGB c, boolean downDirection, uint8_t wait) {
  uint16_t j;
  
  if (downDirection) {  
    for (int i = 0; i < LEG_LENGTH; i++) {
      for (int j = 0; j < N_STRIPS; j++) {
        leds[lights[j][i]] = c;
      }
      FastLED.show();
      FastLED.delay(wait);
    }
  } else {
    for (int i = 0; i < LEG_LENGTH; i++) {
      for (int j = 0; j < N_STRIPS; j++) {
        leds[lights[j][LEG_LENGTH - 1 - i]] = c;
      }
      FastLED.show();
      FastLED.delay(wait);
    }
  }       
}

// Create a stack of colors in either up or down direction
void stack(CRGB c1, CRGB c2, boolean downDirection, uint8_t wait) {
  for (int i = 0; i < N_LEDS; i++) {
    leds[i] = c2;
  }
  if (downDirection) {
    for (int max = LEG_LENGTH; max > 0; max--) {
      for (int j = 0; j < N_STRIPS; j++) {
        leds[lights[j][0]] = c1; // Set the first row to the color 
      }
      FastLED.show();
      FastLED.delay(wait);
      for (int i = 1; i < max; i++) { // Move the colored row down
        for (int j = 0; j < N_STRIPS; j++) {
          leds[lights[j][i]] = c1; // Move the row down
          leds[lights[j][i-1]] = c2; // Clear the previous row
        }
        FastLED.show();
        FastLED.delay(wait);
      }
    }
  } else {
    for (int min = 0; min < LEG_LENGTH; min++) {
      for (int j = 0; j < N_STRIPS; j++) {
        leds[lights[j][LEG_LENGTH - 1]] = c1; // Set the last row to the color
      }
      FastLED.show();
      FastLED.delay(wait);
      for (int i = LEG_LENGTH - 2; i >= min; i--) { // Move the colored row up
        for (int j = 0; j < N_STRIPS; j++) {
          leds[lights[j][i]] = c1; // Move the row down
          leds[lights[j][i+1]] = c2;  // Clear the previous row
        }
        FastLED.show();
        FastLED.delay(wait);
      }
    }
  }    
}

void sweep(uint8_t wait, uint32_t spins) {
  for (int i = 0; i < spins; i++) {
    for (int j = 0; j < N_LEDS; j++) {
      if ((i + j) % LED_PER_ROW < N_COLORS) {
        leds[j] = colors[(i + j) % LED_PER_ROW];
      } else {
        leds[j] = CRGB::Black;
      }
    }
    FastLED.show();
    FastLED.delay(wait);
  }
}



// Sine wave effect
#define PI 3.14159265
void wave(CRGB c, int cycles, uint8_t wait) {
  float y;
  byte  r, g, b, r2, g2, b2;

  // Need to decompose color into its r, g, b elements
  g = c.green;
  r = c.red;
  b = c.blue; 

  for(int x=0; x<(N_LEDS*5); x++)
  {
    for(int i=0; i<N_LEDS; i++) {
      y = sin(PI * (float)cycles * (float)(x + i) / (float)N_LEDS);
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
      leds[i].r = r2;
      leds[i].g = g2;
      leds[i].b = b2;
    }
    FastLED.show();
    FastLED.delay(wait);
  }
}

/* Helper functions */

//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g - b - back to r

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 256)
  {
    case 0:
      r = 256 - WheelPos % 256; // red down
      g = WheelPos % 256;       // green up
      b = 0;                    // blue off
      break;
    case 1:
      g = 256 - WheelPos % 256; // green down
      b = WheelPos % 256;       // blue up
      r = 0;                    // red off
      break;
    case 2:
      b = 256 - WheelPos % 256; // blue down
      r = WheelPos % 256;       // red up
      g = 0;                    // green off
      break;
  }
  return(CRGB(r,g,b));
}

uint32_t dimColor(CRGB c, float fraction) {
  byte  r, g, b;
  g = c.green * fraction;
  r = c.red * fraction;
  b = c.blue * fraction;
  return CRGB(r, g, b);
}


