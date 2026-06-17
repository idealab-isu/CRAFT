// Parameters
pcb_length = 35.56; //[17.78:71.12:0.01]
pcb_width = 25.4; //[12.7:50.8:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.1]

// Geometry
module pcb_body() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  translate([0, 0, 0])
    cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Final Output
module pcb_model() {
  union() {
    pcb_body();
  }
}

// Render the PCB model
pcb_model();