// Parameters
length = 26.2; //[13.1:52.4:0.1]
width = 17.5; //[8.75:35:0.1]
thickness = 1; //[0.5:2:0.1]
corner_radius = 0; //[0:5:0.1]
overlap = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color([0.0, 0.4, 0.2]) { // PCB-like green color
    cube([length, width, thickness], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color([0.1, 0.1, 0.6]) { // Blue color for differentiation
    translate([0, 0, thickness/2 + thickness/2 - overlap])
      cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  battery();
  mod();
}

assembly();