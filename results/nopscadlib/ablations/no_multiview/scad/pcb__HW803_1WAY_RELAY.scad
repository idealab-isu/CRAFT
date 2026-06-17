// Parameters
length = 50; //[25:100:0.5]
width = 26; //[13:52:0.5]
thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 0; //[0:5:0.25]

// PCB Plate - Simple relay module PCB
module pcb_plate() {
  color([0.0, 0.4, 0.2]) { // Green color for PCB
    cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  pcb_plate();
}

assembly();