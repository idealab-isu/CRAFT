// Parameters
pcb_length = 65; //[32.5:130:0.1]
pcb_width = 56; //[28:112:0.1]
pcb_thickness = 1.4; //[0.7:2.8:0.1]

// PCB Main Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green color for PCB
  translate([0, 0, 0])
    cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Complete PCB Model
module pcb_complete_model() {
  union() {
    pcb_main_body();
  }
}

// Render the final output
pcb_complete_model();