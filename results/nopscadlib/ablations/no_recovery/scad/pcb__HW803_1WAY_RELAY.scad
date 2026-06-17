// Parameters
length = 50; //[25:100:0.1]
width = 26; //[13:52:0.1]
thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 0; //[0:5:0.1]

// PCB-style relay module - complete geometry
module mod() {
  color([0.0, 0.4, 0.2]) { // PCB green color
    // PCB Board
    cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();