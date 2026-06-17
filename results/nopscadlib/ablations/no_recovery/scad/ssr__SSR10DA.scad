// Parameters
length = 58; //[29:116:1]
width = 45; //[22.5:90:1]
height = 33; //[16.5:66:1]
corner_radius = 0; //[0:6:0.5]
mounting_holes = 0; //[0:1:1]
terminal_features = 0; //[0:1:1]
eps = 1; //[0.5:2:0.5]

// Solid State Relay (SSR) Module - Simplified Block
module mod() {
  color([0.85, 0.85, 0.8]) { // Off-white color for SSR module
    cube([length, width, height], center=true);
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();