// Parameters
pcb_L = 26.3; //[13.15:52.6:0.1]
pcb_W = 19.5; //[9.75:39:0.1]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 1; //[0.5:2:0.1]
rounding_sphere_R = 1; //[0.5:2:0.1]
mount_hole_d = 2.2; //[1.1:4.4:0.1]
mount_hole_edge_margin = 3.0; //[1.5:6:0.1]
hole_clearance_extra = 0.2; //[0.1:0.6:0.05]
outline_line_w = 0.3; //[0.15:0.8:0.05]
outline_raise_h = 0.15; //[0.05:0.4:0.05]
outline_L = 14.0; //[7:28:0.1]
outline_W = 14.0; //[7:28:0.1]
outline_center_x = 0.0; //[-5:5:0.1]
outline_center_y = 2.0; //[-5:5:0.1]
pad_d = 1.6; //[0.8:3.2:0.1]
pad_h = 0.12; //[0.05:0.3:0.01]
header_pitch = 2.54; //[1.27:5.08:0.01]
header_pins = 5; //[3:8:1]
header_center_x = 0.0; //[-5:5:0.1]
header_center_y = -6.0; //[-10:0:0.1]
trace_w = 0.5; //[0.2:1.5:0.05]
trace_h = 0.05; //[0.02:0.2:0.01]
trace_overlap = 0.6; //[0.3:1.5:0.05]
z_fuse_overlap = 0.2; //[0.1:0.6:0.05]

// PCB Core with Rounded Corners
module pcb_core() {
  difference() {
    minkowski() {
      translate([0, 0, pcb_T/2])
        cube([pcb_L - 2*corner_R, pcb_W - 2*corner_R, pcb_T], center=true);
      sphere(r=rounding_sphere_R);
    }
    // Mounting Holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - mount_hole_edge_margin), y * (pcb_W/2 - mount_hole_edge_margin), 0])
        cylinder(r=mount_hole_d/2, h=pcb_T + hole_clearance_extra, center=true);
    }
  }
}

// Encoder Footprint Outline
module encoder_footprint_outline() {
  union() {
    translate([outline_center_x, outline_center_y + outline_W/2 - outline_line_w/2, pcb_T/2 + outline_raise_h/2 - z_fuse_overlap])
      cube([outline_L, outline_line_w, outline_raise_h], center=true);
    translate([outline_center_x, outline_center_y - outline_W/2 + outline_line_w/2, pcb_T/2 + outline_raise_h/2 - z_fuse_overlap])
      cube([outline_L, outline_line_w, outline_raise_h], center=true);
    translate([outline_center_x - outline_L/2 + outline_line_w/2, outline_center_y, pcb_T/2 + outline_raise_h/2 - z_fuse_overlap])
      cube([outline_line_w, outline_W, outline_raise_h], center=true);
    translate([outline_center_x + outline_L/2 - outline_line_w/2, outline_center_y, pcb_T/2 + outline_raise_h/2 - z_fuse_overlap])
      cube([outline_line_w, outline_W, outline_raise_h], center=true);
  }
}

// Pin Header Pads
module pin_header_pads() {
  for (i = [-2, -1, 0, 1, 2]) {
    translate([header_center_x + i * header_pitch, header_center_y, pcb_T/2 + pad_h/2 - z_fuse_overlap])
      cylinder(r=pad_d/2, h=pad_h, center=true);
  }
}

// Copper Traces
module copper_traces() {
  for (i = [-2, -1, 0, 1, 2]) {
    translate([(outline_center_x + (header_center_x + i * header_pitch))/2, header_center_y, pcb_T/2 + trace_h/2 - z_fuse_overlap])
      cube([abs(outline_center_x - (header_center_x + i * header_pitch)) + trace_overlap + pad_d/2, trace_w, trace_h], center=true);
  }
}

// Complete Model
module complete_model() {
  color([0.0, 0.4, 0.2]) // PCB color
  union() {
    pcb_core();
    encoder_footprint_outline();
    pin_header_pads();
    copper_traces();
  }
}

// Render the complete model
complete_model();