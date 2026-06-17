// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]
corner_radius = 10; //[5:20:1]
edge_chamfer = 1.5; //[0.5:3:0.5]
hole_diameter = 10; //[5:20:1]
hole_edge_margin = 25; //[12:50:1]
hole_spacing_x = 100; //[50:200:1]
hole_spacing_y = 75; //[40:150:1]
hole_rows = 2; //[1:4:1]
hole_cols = 3; //[1:5:1]
hole_clearance_z = 2; //[1:5:1]
chamfer_cutter_extra = 2; //[1:6:1]

// Base shapes
module tooling_plate_body() {
  cube([plate_length, plate_width, plate_thickness], center=true);
}

module corner_radius_cut_cyl_base() {
  rotate([90, 0, 0])
    cylinder(r=corner_radius, h=plate_thickness + 2*hole_clearance_z, center=true);
}

module corner_radius_cut_box_base() {
  cube([2*corner_radius, 2*corner_radius, plate_thickness + 2*hole_clearance_z], center=true);
}

module edge_chamfer_cutter_x_base() {
  cube([plate_length + 2*chamfer_cutter_extra, edge_chamfer*2, edge_chamfer*2], center=true);
}

module edge_chamfer_cutter_y_base() {
  cube([edge_chamfer*2, plate_width + 2*chamfer_cutter_extra, edge_chamfer*2], center=true);
}

module mounting_hole_cutter_base() {
  cylinder(r=hole_diameter/2, h=plate_thickness + 2*hole_clearance_z, center=true);
}

// Operations
module corner_radius_cut_quadrant() {
  intersection() {
    corner_radius_cut_cyl_base();
    corner_radius_cut_box_base();
  }
}

module corner_radius_cuts_all() {
  union() {
    translate([plate_length/2 - corner_radius, plate_width/2 - corner_radius, 0])
      corner_radius_cut_quadrant();
    translate([-plate_length/2 + corner_radius, plate_width/2 - corner_radius, 0])
      corner_radius_cut_quadrant();
    translate([plate_length/2 - corner_radius, -plate_width/2 + corner_radius, 0])
      corner_radius_cut_quadrant();
    translate([-plate_length/2 + corner_radius, -plate_width/2 + corner_radius, 0])
      corner_radius_cut_quadrant();
  }
}

module edge_chamfer() {
  union() {
    translate([0, plate_width/2 - edge_chamfer/2, plate_thickness/2 - edge_chamfer/2])
      rotate([45, 0, 0]) edge_chamfer_cutter_x_base();
    translate([0, -plate_width/2 + edge_chamfer/2, plate_thickness/2 - edge_chamfer/2])
      rotate([45, 0, 0]) edge_chamfer_cutter_x_base();
    translate([plate_length/2 - edge_chamfer/2, 0, plate_thickness/2 - edge_chamfer/2])
      rotate([0, 45, 0]) edge_chamfer_cutter_y_base();
    translate([-plate_length/2 + edge_chamfer/2, 0, plate_thickness/2 - edge_chamfer/2])
      rotate([0, 45, 0]) edge_chamfer_cutter_y_base();
  }
}

module mounting_holes_pattern() {
  union() {
    for (row = [0:hole_rows-1]) {
      for (col = [0:hole_cols-1]) {
        translate([-plate_length/2 + hole_edge_margin + col*hole_spacing_x,
                   -plate_width/2 + hole_edge_margin + row*hole_spacing_y, 0])
          mounting_hole_cutter_base();
      }
    }
  }
}

// Final model
difference() {
  tooling_plate_body();
  corner_radius_cuts_all();
  edge_chamfer();
  mounting_holes_pattern();
}