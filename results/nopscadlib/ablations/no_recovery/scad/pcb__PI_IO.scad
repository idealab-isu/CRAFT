// Parameters
pcb_length = 35.56; //[17.78:71.12:0.1]
pcb_width = 25.4; //[12.7:50.8:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 2.0; //[0.5:6.0:0.1]
edge_chamfer = 0.6; //[0.2:1.5:0.1]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset_x = 3.5; //[2.0:8.0:0.1]
mount_hole_edge_offset_y = 3.5; //[2.0:8.0:0.1]
copper_thickness = 0.05; //[0.02:0.2:0.01]
silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
pad_diameter = 1.8; //[1.0:3.5:0.1]
trace_width = 0.6; //[0.2:2.0:0.1]
component_body_height = 3.0; //[1.0:10.0:0.1]
component_body_length = 6.0; //[2.0:15.0:0.1]
component_body_width = 4.0; //[2.0:12.0:0.1]
overlap = 0.8; //[0.2:2.0:0.1]

// Base Shapes
module pcb_body_base() {
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

module rounded_corner_cyl() {
  cylinder(r=corner_radius, h=pcb_thickness + overlap*2, center=true);
}

module corner_cut_box() {
  cube([corner_radius*2, corner_radius*2, pcb_thickness + overlap*2], center=true);
}

module edge_chamfer_cut_top() {
  cube([pcb_length - edge_chamfer*2, pcb_width - edge_chamfer*2, pcb_thickness], center=true);
}

module edge_chamfer_cut_bottom() {
  cube([pcb_length - edge_chamfer*2, pcb_width - edge_chamfer*2, pcb_thickness], center=true);
}

module mount_hole_cyl() {
  cylinder(r=mount_hole_diameter/2, h=pcb_thickness + overlap*4, center=true);
}

module copper_pad_cyl() {
  cylinder(r=pad_diameter/2, h=copper_thickness + overlap, center=true);
}

module copper_trace_box() {
  cube([pcb_length*0.6, trace_width, copper_thickness + overlap], center=true);
}

module silkscreen_box() {
  cube([pcb_length*0.5, pcb_width*0.08, silkscreen_thickness + overlap], center=true);
}

module component_body_box() {
  cube([component_body_length, component_body_width, component_body_height], center=true);
}

// Operations
module corner_diff_tl() {
  difference() {
    translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]) corner_cut_box();
    translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]) rounded_corner_cyl();
  }
}

module corner_diff_tr() {
  difference() {
    translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]) corner_cut_box();
    translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]) rounded_corner_cyl();
  }
}

module corner_diff_bl() {
  difference() {
    translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]) corner_cut_box();
    translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]) rounded_corner_cyl();
  }
}

module corner_diff_br() {
  difference() {
    translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]) corner_cut_box();
    translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]) rounded_corner_cyl();
  }
}

module pcb_with_rounded_corners() {
  difference() {
    pcb_body_base();
    corner_diff_tl();
    corner_diff_tr();
    corner_diff_bl();
    corner_diff_br();
  }
}

module pcb_with_edge_chamfer() {
  difference() {
    pcb_with_rounded_corners();
    translate([0, 0, pcb_thickness/2]) edge_chamfer_cut_top();
    translate([0, 0, -pcb_thickness/2]) edge_chamfer_cut_bottom();
  }
}

module pcb_body() {
  difference() {
    pcb_with_edge_chamfer();
    translate([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
  }
}

module copper_pads_traces() {
  union() {
    translate([-pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + copper_thickness/2 - overlap/2]) copper_pad_cyl();
    translate([pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + copper_thickness/2 - overlap/2]) copper_pad_cyl();
    translate([0, -pcb_width*0.15, pcb_thickness/2 + copper_thickness/2 - overlap/2]) copper_trace_box();
  }
}

module silkscreen_markings() {
  union() {
    translate([0, pcb_width*0.25, pcb_thickness/2 + silkscreen_thickness/2 - overlap/2]) silkscreen_box();
    translate([0, pcb_width*0.35, pcb_thickness/2 + silkscreen_thickness/2 - overlap/2]) silkscreen_box();
  }
}

module components() {
  union() {
    translate([0, 0, pcb_thickness/2 + component_body_height/2 - overlap]) component_body_box();
    translate([-pcb_length*0.25, pcb_width*0.15, pcb_thickness/2 + component_body_height/2 - overlap]) component_body_box();
  }
}

// Final Model
module pcb_complete_model() {
  union() {
    pcb_body();
    copper_pads_traces();
    silkscreen_markings();
    components();
  }
}

// Render the complete PCB model
color([0.0, 0.4, 0.2]) pcb_complete_model(); // PCB color