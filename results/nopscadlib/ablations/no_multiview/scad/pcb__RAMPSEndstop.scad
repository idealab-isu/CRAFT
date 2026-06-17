// Parameters
pcb_length = 40.0; //[20.0:80.0:0.5]
pcb_width = 16.0; //[8.0:32.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]

// PCB Module
module pcb_body() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Final Model
pcb_body();