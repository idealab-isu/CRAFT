// Parameters
pcb_length = 24.8; //[12.4:49.6:0.1]
pcb_width = 14.6; //[7.3:29.2:0.1]
pcb_thickness = 1.0; //[0.5:2.0:0.1]
corner_radius = 1.5; //[0.5:3.0:0.1]
mount_hole_diameter = 2.2; //[1.0:4.0:0.1]
mount_hole_edge_offset = 2.5; //[1.0:5.0:0.1]
hole_cut_extra = 0.5; //[0.2:2.0:0.1]
silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
silkscreen_margin = 0.8; //[0.3:2.0:0.1]
silkscreen_line_width = 0.4; //[0.2:1.0:0.05]
copper_thickness = 0.035; //[0.01:0.1:0.005]
pad_diameter = 1.6; //[0.8:3.0:0.1]
pad_pitch = 2.54; //[1.27:5.08:0.01]
pad_row_y_offset = 3.0; //[1.5:6.0:0.1]
edge_connector_length = 10.0; //[5.0:20.0:0.1]
edge_connector_depth = 3.0; //[1.5:6.0:0.1]
feature_overlap = 0.2; //[0.05:1.0:0.05]

// Base shapes
module pcb_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=pcb_thickness, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_diameter/2, h=pcb_thickness + hole_cut_extra, center=true);
}

module silkscreen_box(size, pos) {
  translate(pos)
    cube(size, center=true);
}

module pad(pos) {
  translate(pos)
    cylinder(r=pad_diameter/2, h=copper_thickness, center=true);
}

module edge_connector() {
  translate([0, -pcb_width/2 + edge_connector_depth/2, pcb_thickness/2 + copper_thickness/2 - feature_overlap])
    cube([edge_connector_length, edge_connector_depth, copper_thickness], center=true);
}

// Operations
module rounded_corners() {
  hull() {
    pcb_corner_cyl([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]);
    pcb_corner_cyl([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]);
    pcb_corner_cyl([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]);
    pcb_corner_cyl([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]);
  }
}

module mounting_holes() {
  union() {
    mount_hole([-pcb_length/2 + mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0]);
    mount_hole([-pcb_length/2 + mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0]);
  }
}

module pcb_body() {
  difference() {
    rounded_corners();
    mounting_holes();
  }
}

module silkscreen_markings() {
  union() {
    silkscreen_box([pcb_length - 2*silkscreen_margin, silkscreen_line_width, silkscreen_thickness],
                   [0, pcb_width/2 - silkscreen_margin - silkscreen_line_width/2, pcb_thickness/2 + silkscreen_thickness/2 - feature_overlap]);
    silkscreen_box([pcb_length - 2*silkscreen_margin, silkscreen_line_width, silkscreen_thickness],
                   [0, -pcb_width/2 + silkscreen_margin + silkscreen_line_width/2, pcb_thickness/2 + silkscreen_thickness/2 - feature_overlap]);
    silkscreen_box([silkscreen_line_width, pcb_width - 2*silkscreen_margin, silkscreen_thickness],
                   [-pcb_length/2 + silkscreen_margin + silkscreen_line_width/2, 0, pcb_thickness/2 + silkscreen_thickness/2 - feature_overlap]);
    silkscreen_box([silkscreen_line_width, pcb_width - 2*silkscreen_margin, silkscreen_thickness],
                   [pcb_length/2 - silkscreen_margin - silkscreen_line_width/2, 0, pcb_thickness/2 + silkscreen_thickness/2 - feature_overlap]);
  }
}

module copper_pads() {
  union() {
    pad([-pad_pitch*1.5, pad_row_y_offset, pcb_thickness/2 + copper_thickness/2 - feature_overlap]);
    pad([-pad_pitch*0.5, pad_row_y_offset, pcb_thickness/2 + copper_thickness/2 - feature_overlap]);
    pad([pad_pitch*0.5, pad_row_y_offset, pcb_thickness/2 + copper_thickness/2 - feature_overlap]);
    pad([pad_pitch*1.5, pad_row_y_offset, pcb_thickness/2 + copper_thickness/2 - feature_overlap]);
  }
}

module copper_features() {
  union() {
    copper_pads();
    edge_connector();
  }
}

// Final model
module complete_model() {
  union() {
    pcb_body();
    silkscreen_markings();
    copper_features();
  }
}

// Render the complete model
color([0.0, 0.4, 0.2]) // PCB color
complete_model();