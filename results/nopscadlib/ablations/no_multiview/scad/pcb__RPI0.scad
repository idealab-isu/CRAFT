// Parameters
pcb_length = 65; //[32.5:130:0.1]
pcb_width = 30; //[15:60:0.1]
pcb_thickness = 1.4; //[0.7:2.8:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Complete SBC Model
module sbc_complete_model() {
  pcb_main_body();
}

// Render the final model
sbc_complete_model();