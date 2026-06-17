// Parameters
pcb_L = 21; //[10.5:42:0.1]
pcb_W = 18; //[9:36:0.1]
pcb_T = 1.2; //[0.6:2.4:0.1]
mask_T = 0.05; //[0.02:0.15:0.01]
silk_T = 0.02; //[0.01:0.08:0.01]
copper_T = 0.035; //[0.018:0.105:0.001]
hole_D = 2.2; //[1.2:4.4:0.1]
hole_edge_margin = 2.5; //[1.5:5:0.1]
chamfer_size = 0.6; //[0.2:1.5:0.1]
trace_W = 0.6; //[0.2:2:0.1]
trace_margin = 2.2; //[1:5:0.1]
trace_overlap = 0.8; //[0.5:2:0.1]
silk_line_W = 0.4; //[0.2:1.2:0.1]
silk_inset = 1.2; //[0.6:3:0.1]
comp_body_L = 6; //[3:12:0.1]
comp_body_W = 4; //[2:10:0.1]
comp_body_H = 1.6; //[0.8:6:0.1]
comp_offset_x = 0; //[-5:5:0.1]
comp_offset_y = 0; //[-5:5:0.1]

// PCB Body with Edge Chamfers
module pcb_body() {
  difference() {
    color([0.0, 0.4, 0.2]) // PCB color
    cube([pcb_L, pcb_W, pcb_T], center=true);
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - chamfer_size/2), y * (pcb_W/2 - chamfer_size/2), 0])
      rotate([0, 0, 45])
      cube([chamfer_size, chamfer_size, pcb_T*2], center=true);
    }
  }
}

// Mounting Holes
module mounting_holes() {
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * (pcb_L/2 - hole_edge_margin), y * (pcb_W/2 - hole_edge_margin), 0])
    cylinder(h=pcb_T*3, r=hole_D/2, center=true);
  }
}

// Copper Traces
module copper_traces() {
  color([0.72, 0.45, 0.2]) // Copper color
  union() {
    translate([0, 0, pcb_T/2 + copper_T/2 - trace_overlap])
    cube([pcb_L - 2*trace_margin, trace_W, copper_T], center=true);
    translate([0, 0, pcb_T/2 + copper_T/2 - trace_overlap])
    cube([trace_W, pcb_W - 2*trace_margin, copper_T], center=true);
  }
}

// Silkscreen
module silkscreen() {
  color([1, 1, 1]) // White silkscreen
  union() {
    translate([0, pcb_W/2 - silk_inset, pcb_T/2 + silk_T/2 - trace_overlap])
    cube([pcb_L - 2*silk_inset, silk_line_W, silk_T], center=true);
    translate([pcb_L/2 - silk_inset, 0, pcb_T/2 + silk_T/2 - trace_overlap])
    cube([silk_line_W, pcb_W - 2*silk_inset, silk_T], center=true);
  }
}

// Solder Mask
module solder_mask() {
  color([0.0, 0.4, 0.2, 0.5]) // Semi-transparent green
  union() {
    translate([0, 0, pcb_T/2 + mask_T/2 - trace_overlap])
    cube([pcb_L, pcb_W, mask_T], center=true);
    translate([0, 0, -pcb_T/2 - mask_T/2 + trace_overlap])
    cube([pcb_L, pcb_W, mask_T], center=true);
  }
}

// Component Placeholder
module component_placeholder() {
  color([0.85, 0.85, 0.8]) // Off-white for components
  translate([comp_offset_x, comp_offset_y, pcb_T/2 + comp_body_H/2 - trace_overlap])
  cube([comp_body_L, comp_body_W, comp_body_H], center=true);
}

// Complete PCB Model
module pcb_complete_model() {
  union() {
    difference() {
      pcb_body();
      mounting_holes();
    }
    solder_mask();
    copper_traces();
    silkscreen();
    component_placeholder();
  }
}

// Render the complete PCB model
pcb_complete_model();