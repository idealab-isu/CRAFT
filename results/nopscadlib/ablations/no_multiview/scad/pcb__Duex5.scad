// Parameters
pcb_length = 123; //[61.5:246:0.5]
pcb_width = 100; //[50:200:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]

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

// Render the final model
pcb_complete_model();