// Parameters
length = 63; //[31.5:126:0.5]
width = 45; //[22.5:90:0.5]
height = 23; //[11.5:46:0.5]
corner_radius = 0; //[0:6:0.5]
origin_reference = 0; //[0:0:1]

// Solid State Relay (SSR) Module - Simplified Envelope
module mod() {
  color([0.85, 0.85, 0.8]) { // Off-white for SSR body
    cube([length, width, height], center=true);
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();