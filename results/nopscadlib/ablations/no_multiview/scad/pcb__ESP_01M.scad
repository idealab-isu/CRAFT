// Parameters
pcb_L = 18.0; //[9.0:36.0:0.1]
pcb_W = 18.0; //[9.0:36.0:0.1]
pcb_T = 0.8;  //[0.4:1.6:0.05]

// PCB Module
module pcb_plate() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  translate([0, 0, 0])
    cube([pcb_L, pcb_W, pcb_T], center=true);
}

// Final Output
pcb_plate();