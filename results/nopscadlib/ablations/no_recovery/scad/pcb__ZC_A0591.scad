// Parameters
length = 35.0; //[17.5:70.0:0.1]
width = 32.0; //[16.0:64.0:0.1]
thickness = 1.6; //[0.8:3.2:0.1]

// PCB Module
module pcb() {
  color([0.0, 0.4, 0.2]) { // Green color for PCB
    cube([length, width, thickness], center=true);
  }
}

// Assembly
module assembly() {
  pcb();
}

assembly();