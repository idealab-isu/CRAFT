// Parameters
pcb_L = 24.8; //[12.4:49.6:0.1]
pcb_W = 14.6; //[7.3:29.2:0.1]
pcb_T = 1.0; //[0.5:2.0:0.1]
corner_R = 1.5; //[0.5:3.0:0.1]
mount_hole_D = 2.0; //[1.0:4.0:0.1]
mount_edge_offset = 2.5; //[1.0:5.0:0.1]
hole_clearance_Z = 0.2; //[0.1:1.0:0.1]
silk_T = 0.05; //[0.02:0.2:0.01]
silk_margin = 0.8; //[0.3:2.0:0.1]
copper_T = 0.035; //[0.01:0.1:0.005]
pad_D = 1.6; //[0.8:3.2:0.1]
pad_pitch = 2.54; //[1.27:5.08:0.01]
trace_W = 0.4; //[0.2:1.0:0.05]
trace_L = 10.0; //[5.0:20.0:0.5]
edge_cutout_W = 6.0; //[2.0:12.0:0.5]
edge_cutout_D = 2.0; //[0.5:5.0:0.1]
connect_overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module pcb_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_R, h=pcb_T, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_D/2, h=pcb_T + hole_clearance_Z, center=true);
}

module edge_connector_cutout(pos) {
  translate(pos)
    cube([edge_cutout_D, edge_cutout_W, pcb_T + hole_clearance_Z], center=true);
}

module silk_border_outer() {
  translate([0, 0, pcb_T/2 + silk_T/2 - connect_overlap])
    cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T], center=true);
}

module silk_border_inner_cut() {
  translate([0, 0, pcb_T/2 + silk_T/2 - connect_overlap])
    cube([pcb_L - 2*(silk_margin + trace_W), pcb_W - 2*(silk_margin + trace_W), silk_T + hole_clearance_Z], center=true);
}

module copper_pad(pos) {
  translate(pos)
    cylinder(r=pad_D/2, h=copper_T, center=true);
}

module copper_trace() {
  translate([-pcb_L/2 + mount_edge_offset + 2*pad_pitch + trace_L/2 - connect_overlap, 0, pcb_T/2 + copper_T/2 - connect_overlap])
    cube([trace_L, trace_W, copper_T], center=true);
}

// Operations
module rounded_corners() {
  hull() {
    pcb_corner_cyl([pcb_L/2 - corner_R, pcb_W/2 - corner_R, 0]);
    pcb_corner_cyl([-pcb_L/2 + corner_R, pcb_W/2 - corner_R, 0]);
    pcb_corner_cyl([-pcb_L/2 + corner_R, -pcb_W/2 + corner_R, 0]);
    pcb_corner_cyl([pcb_L/2 - corner_R, -pcb_W/2 + corner_R, 0]);
  }
}

module mounting_holes() {
  union() {
    mount_hole([-pcb_L/2 + mount_edge_offset, -pcb_W/2 + mount_edge_offset, 0]);
    mount_hole([pcb_L/2 - mount_edge_offset, -pcb_W/2 + mount_edge_offset, 0]);
    mount_hole([-pcb_L/2 + mount_edge_offset, pcb_W/2 - mount_edge_offset, 0]);
    mount_hole([pcb_L/2 - mount_edge_offset, pcb_W/2 - mount_edge_offset, 0]);
  }
}

module edge_connector_cutouts() {
  edge_connector_cutout([pcb_L/2 - edge_cutout_D/2, 0, 0]);
}

module pcb_body() {
  difference() {
    rounded_corners();
    mounting_holes();
    edge_connector_cutouts();
  }
}

module silkscreen_markings() {
  difference() {
    silk_border_outer();
    silk_border_inner_cut();
  }
}

module copper_pads_traces() {
  union() {
    copper_pad([-pcb_L/2 + mount_edge_offset + pad_pitch, 0, pcb_T/2 + copper_T/2 - connect_overlap]);
    copper_pad([-pcb_L/2 + mount_edge_offset + 2*pad_pitch, 0, pcb_T/2 + copper_T/2 - connect_overlap]);
    copper_pad([-pcb_L/2 + mount_edge_offset + 3*pad_pitch, 0, pcb_T/2 + copper_T/2 - connect_overlap]);
    copper_trace();
  }
}

// Final Output
module pcb_complete() {
  union() {
    pcb_body();
    silkscreen_markings();
    copper_pads_traces();
  }
}

// Render the PCB
color([0.0, 0.4, 0.2]) pcb_complete(); // PCB in green