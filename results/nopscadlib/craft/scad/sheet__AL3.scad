// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]
edge_chamfer = 1; //[0.5:3:0.5]
corner_radius = 8; //[4:16:1]
hole_diameter = 8; //[3:16:0.5]
hole_edge_offset = 20; //[10:40:1]
label_length = 80; //[40:160:1]
label_width = 30; //[15:60:1]
label_depth = 0.5; //[0.2:2:0.1]
label_edge_margin = 15; //[8:30:1]
overlap = 1; //[0.5:2:0.5]

// Main tooling plate
module tooling_plate_sheet() {
  cube([plate_length, plate_width, plate_thickness], center=true);
}

// Edge chamfer
module edge_chamfer() {
  difference() {
    cube([plate_length, plate_width, edge_chamfer], center=true);
    translate([0, 0, -overlap])
      cube([plate_length - 2*edge_chamfer, plate_width - 2*edge_chamfer, edge_chamfer + 2*overlap], center=true);
  }
}

// Corner radius cutout
module corner_radius_cutout(x, y) {
  difference() {
    translate([x, y, 0])
      cube([corner_radius, corner_radius, plate_thickness + 2*overlap], center=true);
    translate([x, y, 0])
      cylinder(r=corner_radius, h=plate_thickness + 2*overlap, center=true);
  }
}

// Mounting holes
module mounting_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_diameter/2, h=plate_thickness + 2*overlap, center=true);
}

// Engraved label recess
module engraved_label() {
  translate([-plate_length/2 + label_edge_margin + label_length/2, plate_width/2 - label_edge_margin - label_width/2, plate_thickness/2 - label_depth/2])
    cube([label_length, label_width, label_depth + 2*overlap], center=true);
}

// Complete model
module complete_model() {
  difference() {
    tooling_plate_sheet();
    translate([0, 0, plate_thickness/2 - edge_chamfer/2])
      edge_chamfer();
    corner_radius_cutout(plate_length/2 - corner_radius/2, plate_width/2 - corner_radius/2);
    corner_radius_cutout(-plate_length/2 + corner_radius/2, plate_width/2 - corner_radius/2);
    corner_radius_cutout(plate_length/2 - corner_radius/2, -plate_width/2 + corner_radius/2);
    corner_radius_cutout(-plate_length/2 + corner_radius/2, -plate_width/2 + corner_radius/2);
    mounting_hole(-plate_length/2 + hole_edge_offset, -plate_width/2 + hole_edge_offset);
    mounting_hole(plate_length/2 - hole_edge_offset, -plate_width/2 + hole_edge_offset);
    mounting_hole(plate_length/2 - hole_edge_offset, plate_width/2 - hole_edge_offset);
    mounting_hole(-plate_length/2 + hole_edge_offset, plate_width/2 - hole_edge_offset);
    engraved_label();
  }
}

// Render the complete model
color("Silver") complete_model();