// Parameters
length_mm = 58; //[29:116:1]
width_mm = 45; //[22.5:90:1]
height_mm = 33; //[16.5:66:1]
corner_radius_mm = 0; //[0:8:0.5]

// Main body of the SSR module
module mod() {
  color([0.85, 0.85, 0.8]) { // Off-white color for the enclosure
    cube([length_mm, width_mm, height_mm], center=true);
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();