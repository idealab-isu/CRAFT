// Parameters
length = 26.2; //[13.1:52.4:0.1]
width = 17.5; //[8.75:35:0.1]
thickness = 1; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color([0.85, 0.85, 0.8]) { // Off-white for 3D printed PLA
    // Main body
    cube([length, width, thickness], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.1, 0.1, 0.6]) { // Blue for PCB-like appearance
    // Main body
    cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  // Place battery at origin
  battery();
  // Place mod on top of battery
  translate([0, 0, thickness]) mod();
}

assembly();