// Parameters
length = 35; //[17.5:70:0.5]
width = 32; //[16:64:0.5]
thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 0; //[0:6:0.5]

// PCB Module - complete geometry
module mod() {
  color([0.0, 0.4, 0.2]) { // Green color for PCB
    // PCB Board
    cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();