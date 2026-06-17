// Parameters
pcb_length = 40.0; //[20.0:80.0:0.5]
pcb_width = 16.0; //[8.0:32.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 2.0; //[0.5:5.0:0.1]
hole_diameter = 3.0; //[1.5:6.0:0.1]
hole_edge_margin = 3.5; //[2.0:7.0:0.1]
copper_thickness = 0.05; //[0.01:0.2:0.01]
silkscreen_thickness = 0.05; //[0.01:0.2:0.01]
outline_thickness = 0.05; //[0.01:0.2:0.01]
feature_overlap = 0.5; //[0.2:2.0:0.1]
pad_diameter = 1.8; //[0.8:4.0:0.1]
pad_pitch = 2.54; //[1.27:5.08:0.01]
pad_row_count = 6; //[2:20:1]
pad_row_y_offset = 4.0; //[2.0:7.0:0.1]
silk_border_inset = 1.0; //[0.5:3.0:0.1]
silk_line_width = 0.6; //[0.2:1.5:0.1]
component_outline_length = 18.0; //[8.0:36.0:0.5]
component_outline_width = 8.0; //[4.0:14.0:0.5]
component_outline_line_width = 0.6; //[0.2:1.5:0.1]
component_outline_x_offset = 0.0; //[-10.0:10.0:0.5]
component_outline_y_offset = 0.0; //[-4.0:4.0:0.5]

// Base Shapes
module pcb_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

module rounded_corner_cutout_cyl() {
  cylinder(r=corner_radius, h=pcb_thickness + feature_overlap*2, center=true);
}

module rounded_corner_cutout_box() {
  cube([corner_radius*2, corner_radius*2, pcb_thickness + feature_overlap*2], center=true);
}

module mounting_hole_cyl() {
  cylinder(r=hole_diameter/2, h=pcb_thickness + feature_overlap*2, center=true);
}

module copper_pad_cyl() {
  color([0.72, 0.45, 0.2]) // Copper color
  cylinder(r=pad_diameter/2, h=copper_thickness + feature_overlap, center=true);
}

module silk_border_horiz() {
  color("White")
  cube([pcb_length - 2*silk_border_inset, silk_line_width, silkscreen_thickness + feature_overlap], center=true);
}

module silk_border_vert() {
  color("White")
  cube([silk_line_width, pcb_width - 2*silk_border_inset, silkscreen_thickness + feature_overlap], center=true);
}

module component_outline_horiz() {
  color("White")
  cube([component_outline_length, component_outline_line_width, outline_thickness + feature_overlap], center=true);
}

module component_outline_vert() {
  color("White")
  cube([component_outline_line_width, component_outline_width, outline_thickness + feature_overlap], center=true);
}

// Operations
module rounded_corners() {
  difference() {
    pcb_body();
    translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
      difference() { rounded_corner_cutout_box(); rounded_corner_cutout_cyl(); }
    translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
      difference() { rounded_corner_cutout_box(); rounded_corner_cutout_cyl(); }
    translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
      difference() { rounded_corner_cutout_box(); rounded_corner_cutout_cyl(); }
    translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
      difference() { rounded_corner_cutout_box(); rounded_corner_cutout_cyl(); }
  }
}

module mounting_holes() {
  difference() {
    rounded_corners();
    translate([-pcb_length/2 + hole_edge_margin, pcb_width/2 - hole_edge_margin, 0]) mounting_hole_cyl();
    translate([pcb_length/2 - hole_edge_margin, pcb_width/2 - hole_edge_margin, 0]) mounting_hole_cyl();
    translate([-pcb_length/2 + hole_edge_margin, -pcb_width/2 + hole_edge_margin, 0]) mounting_hole_cyl();
    translate([pcb_length/2 - hole_edge_margin, -pcb_width/2 + hole_edge_margin, 0]) mounting_hole_cyl();
  }
}

module copper_pads() {
  union() {
    for (i = [0:pad_row_count-1]) {
      translate([-(pad_pitch*(pad_row_count-1))/2 + pad_pitch*i, -pcb_width/2 + pad_row_y_offset, pcb_thickness/2 + (copper_thickness + feature_overlap)/2 - feature_overlap])
        copper_pad_cyl();
    }
  }
}

module silkscreen_markings() {
  union() {
    translate([0, pcb_width/2 - silk_border_inset - silk_line_width/2, pcb_thickness/2 + (silkscreen_thickness + feature_overlap)/2 - feature_overlap])
      silk_border_horiz();
    translate([0, -pcb_width/2 + silk_border_inset + silk_line_width/2, pcb_thickness/2 + (silkscreen_thickness + feature_overlap)/2 - feature_overlap])
      silk_border_horiz();
    translate([-pcb_length/2 + silk_border_inset + silk_line_width/2, 0, pcb_thickness/2 + (silkscreen_thickness + feature_overlap)/2 - feature_overlap])
      silk_border_vert();
    translate([pcb_length/2 - silk_border_inset - silk_line_width/2, 0, pcb_thickness/2 + (silkscreen_thickness + feature_overlap)/2 - feature_overlap])
      silk_border_vert();
  }
}

module components_outline() {
  union() {
    translate([component_outline_x_offset, component_outline_y_offset + component_outline_width/2 - component_outline_line_width/2, pcb_thickness/2 + (outline_thickness + feature_overlap)/2 - feature_overlap])
      component_outline_horiz();
    translate([component_outline_x_offset, component_outline_y_offset - component_outline_width/2 + component_outline_line_width/2, pcb_thickness/2 + (outline_thickness + feature_overlap)/2 - feature_overlap])
      component_outline_horiz();
    translate([component_outline_x_offset - component_outline_length/2 + component_outline_line_width/2, component_outline_y_offset, pcb_thickness/2 + (outline_thickness + feature_overlap)/2 - feature_overlap])
      component_outline_vert();
    translate([component_outline_x_offset + component_outline_length/2 - component_outline_line_width/2, component_outline_y_offset, pcb_thickness/2 + (outline_thickness + feature_overlap)/2 - feature_overlap])
      component_outline_vert();
  }
}

// Final Output
union() {
  mounting_holes();
  copper_pads();
  silkscreen_markings();
  components_outline();
}