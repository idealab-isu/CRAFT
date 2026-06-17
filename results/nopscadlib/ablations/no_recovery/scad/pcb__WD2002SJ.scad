// Parameters
length = 78; //[39:156:0.5]
width = 47; //[23.5:94:0.5]
thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 0; //[0:10:0.5]

// PCB Plate - complete geometry
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