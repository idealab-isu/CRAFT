// Parameters
pcb_length = 20.0; //[10.0:40.0:0.1]
pcb_width = 14.0; //[7.0:28.0:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
hole_diameter = 2.2; //[1.0:4.4:0.1]
hole_edge_offset = 2.0; //[1.0:4.0:0.1]
edge_chamfer_size = 1.0; //[0.5:2.0:0.1]
silkscreen_line_width = 0.3; //[0.15:0.6:0.05]
silkscreen_height = 0.1; //[0.05:0.3:0.05]
silkscreen_inset = 0.5; //[0.2:1.5:0.1]
placeholder_height = 1.0; //[0.5:3.0:0.1]
placeholder_margin = 1.5; //[0.5:3.0:0.1]
header_pin_diameter = 1.0; //[0.6:1.6:0.1]
header_pin_height = 6.0; //[3.0:12.0:0.5]
header_row_length = 12.0; //[6.0:18.0:0.5]
header_row_width = 2.5; //[1.5:4.0:0.1]
header_row_thickness = 2.0; //[1.0:4.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Mounting Holes
module mounting_hole(position) {
  translate(position)
    cylinder(h=pcb_thickness + 2*overlap, r=hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    mounting_hole([(-pcb_length/2 + hole_edge_offset), (-pcb_width/2 + hole_edge_offset), 0]);
    mounting_hole([(pcb_length/2 - hole_edge_offset), (-pcb_width/2 + hole_edge_offset), 0]);
    mounting_hole([(-pcb_length/2 + hole_edge_offset), (pcb_width/2 - hole_edge_offset), 0]);
    mounting_hole([(pcb_length/2 - hole_edge_offset), (pcb_width/2 - hole_edge_offset), 0]);
  }
}

// Edge Chamfers
module edge_chamfer_cut(position) {
  translate(position)
    cube([edge_chamfer_size, edge_chamfer_size, pcb_thickness + 2*overlap], center=true);
}

module edge_chamfer() {
  union() {
    edge_chamfer_cut([(pcb_length/2 - edge_chamfer_size/2), (pcb_width/2 - edge_chamfer_size/2), 0]);
    edge_chamfer_cut([(-pcb_length/2 + edge_chamfer_size/2), (pcb_width/2 - edge_chamfer_size/2), 0]);
    edge_chamfer_cut([(pcb_length/2 - edge_chamfer_size/2), (-pcb_width/2 + edge_chamfer_size/2), 0]);
    edge_chamfer_cut([(-pcb_length/2 + edge_chamfer_size/2), (-pcb_width/2 + edge_chamfer_size/2), 0]);
  }
}

// PCB with Holes and Chamfers
module pcb_with_holes_and_chamfer() {
  difference() {
    pcb_main_body();
    mounting_holes();
    edge_chamfer();
  }
}

// Silkscreen Outline
module silkscreen_outline() {
  difference() {
    translate([0, 0, pcb_thickness/2 + silkscreen_height/2 - overlap/2])
      cube([pcb_length - 2*silkscreen_inset, pcb_width - 2*silkscreen_inset, silkscreen_height], center=true);
    translate([0, 0, pcb_thickness/2 + silkscreen_height/2 - overlap/2])
      cube([pcb_length - 2*(silkscreen_inset + silkscreen_line_width), pcb_width - 2*(silkscreen_inset + silkscreen_line_width), silkscreen_height + 2*overlap], center=true);
  }
}

// Component Placeholders
module component_placeholder_1() {
  translate([(-pcb_length/2 + placeholder_margin) + ((pcb_length - 2*placeholder_margin) * 0.55)/2, 0, pcb_thickness/2 + placeholder_height/2 - overlap])
    cube([(pcb_length - 2*placeholder_margin) * 0.55, (pcb_width - 2*placeholder_margin) * 0.45, placeholder_height], center=true);
}

module component_placeholder_2() {
  translate([(pcb_length/2 - placeholder_margin) - ((pcb_length - 2*placeholder_margin) * 0.35)/2, (pcb_width/2 - placeholder_margin) - ((pcb_width - 2*placeholder_margin) * 0.35)/2, pcb_thickness/2 + placeholder_height/2 - overlap])
    cube([(pcb_length - 2*placeholder_margin) * 0.35, (pcb_width - 2*placeholder_margin) * 0.35, placeholder_height], center=true);
}

module component_placeholders() {
  union() {
    component_placeholder_1();
    component_placeholder_2();
  }
}

// Pin Headers
module pin_header_body() {
  translate([0, (pcb_width/2 - header_row_width/2 - silkscreen_inset), pcb_thickness/2 + header_row_thickness/2 - overlap])
    cube([header_row_length, header_row_width, header_row_thickness], center=true);
}

module pin_header_pin(position) {
  translate(position)
    cylinder(h=header_pin_height, r=header_pin_diameter/2, center=true);
}

module pin_headers() {
  union() {
    pin_header_body();
    pin_header_pin([(-header_row_length/2) + (header_row_length/6), (pcb_width/2 - header_row_width/2 - silkscreen_inset), pcb_thickness/2 + header_pin_height/2 - overlap]);
    pin_header_pin([(-header_row_length/2) + (header_row_length/2), (pcb_width/2 - header_row_width/2 - silkscreen_inset), pcb_thickness/2 + header_pin_height/2 - overlap]);
    pin_header_pin([(-header_row_length/2) + (header_row_length*5/6), (pcb_width/2 - header_row_width/2 - silkscreen_inset), pcb_thickness/2 + header_pin_height/2 - overlap]);
  }
}

// Complete Model
module complete_model() {
  union() {
    pcb_with_holes_and_chamfer();
    silkscreen_outline();
    component_placeholders();
    pin_headers();
  }
}

// Render the complete model
complete_model();