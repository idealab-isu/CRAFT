// Parameters
pcb_length = 40.0; //[20.0:80.0:0.5]
pcb_width = 16.0; //[8.0:32.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 2.0; //[1.0:4.0:0.25]
edge_chamfer = 0.6; //[0.2:1.2:0.1]
hole_diameter = 3.2; //[2.0:4.0:0.1]
hole_edge_offset_x = 4.0; //[2.0:8.0:0.5]
hole_edge_offset_y = 3.0; //[2.0:6.0:0.5]
hole_cut_extra = 0.6; //[0.2:2.0:0.1]
copper_thickness = 0.05; //[0.02:0.2:0.01]
silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
pad_diameter = 1.8; //[1.0:3.0:0.1]
trace_width = 0.8; //[0.3:2.0:0.1]
component_body_height = 3.0; //[1.5:8.0:0.5]
component_body_size_x = 10.0; //[5.0:20.0:0.5]
component_body_size_y = 6.0; //[3.0:12.0:0.5]
overlap = 0.8; //[0.5:2.0:0.1]

// Base shapes
module pcb_core_box() {
  cube([pcb_length - 2*(corner_radius + edge_chamfer), pcb_width - 2*(corner_radius + edge_chamfer), pcb_thickness - 2*edge_chamfer], center=true);
}

module pcb_rounding_sphere() {
  sphere(r=corner_radius + edge_chamfer);
}

module hole_cutter_cyl() {
  cylinder(h=pcb_thickness + 2*hole_cut_extra, r=hole_diameter/2, center=true);
}

module copper_pad_cyl() {
  cylinder(h=copper_thickness + overlap, r=pad_diameter/2, center=true);
}

module copper_trace_box() {
  cube([pcb_length*0.55, trace_width, copper_thickness + overlap], center=true);
}

module silkscreen_line_box() {
  cube([pcb_length*0.85, trace_width*0.6, silkscreen_thickness + overlap], center=true);
}

module component_body_box() {
  cube([component_body_size_x, component_body_size_y, component_body_height], center=true);
}

// PCB body with rounded corners and edge chamfer
module pcb_body() {
  minkowski() {
    pcb_core_box();
    pcb_rounding_sphere();
  }
}

// Mounting holes
module mounting_holes() {
  union() {
    translate([-pcb_length/2 + hole_edge_offset_x, -pcb_width/2 + hole_edge_offset_y, 0]) hole_cutter_cyl();
    translate([pcb_length/2 - hole_edge_offset_x, -pcb_width/2 + hole_edge_offset_y, 0]) hole_cutter_cyl();
    translate([-pcb_length/2 + hole_edge_offset_x, pcb_width/2 - hole_edge_offset_y, 0]) hole_cutter_cyl();
    translate([pcb_length/2 - hole_edge_offset_x, pcb_width/2 - hole_edge_offset_y, 0]) hole_cutter_cyl();
  }
}

// PCB with holes
module pcb_with_holes() {
  difference() {
    pcb_body();
    mounting_holes();
  }
}

// Copper pads and traces
module copper_pads_traces() {
  union() {
    translate([-pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + (copper_thickness + overlap)/2 - overlap]) copper_pad_cyl();
    translate([pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + (copper_thickness + overlap)/2 - overlap]) copper_pad_cyl();
    translate([0, pcb_width*0.2, pcb_thickness/2 + (copper_thickness + overlap)/2 - overlap]) copper_pad_cyl();
    translate([0, -pcb_width*0.15, pcb_thickness/2 + (copper_thickness + overlap)/2 - overlap]) copper_trace_box();
  }
}

// Silkscreen markings
module silkscreen_markings() {
  translate([0, pcb_width*0.35, pcb_thickness/2 + (silkscreen_thickness + overlap)/2 - overlap]) silkscreen_line_box();
}

// Placeholder components
module components() {
  translate([0, 0, pcb_thickness/2 + component_body_height/2 - overlap]) component_body_box();
}

// Complete PCB
module pcb_complete_union() {
  union() {
    pcb_with_holes();
    copper_pads_traces();
    silkscreen_markings();
    components();
  }
}

// Final output
pcb_complete_union();