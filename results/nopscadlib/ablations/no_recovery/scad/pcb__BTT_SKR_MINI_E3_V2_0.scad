// Parameters
pcb_length = 100.75; //[50.375:201.5:0.25]
pcb_width = 70.25; //[35.125:140.5:0.25]
pcb_thickness = 1.6; //[0.8:3.2:0.1]

// Geometry
module pcb_plate() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  translate([0, 0, 0])
    cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Final Output
pcb_plate();