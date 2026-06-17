// Parameters
pcb_length = 85.0; //[42.5:170.0:0.5]
pcb_width = 56.0; //[28.0:112.0:0.5]
pcb_thickness = 1.4; //[0.7:2.8:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  translate([0, 0, 0])
    cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Complete SBC Model
module sbc_complete_model() {
  union() {
    pcb_main_body();
  }
}

// Render the final model
sbc_complete_model();