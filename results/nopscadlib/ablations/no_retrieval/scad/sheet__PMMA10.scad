// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150; //[75:300:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6; //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
edge_overlap = 1; //[0.5:2:0.5]
chamfer_size = 1; //[0.5:3:0.5]
fillet_radius = 1.5; //[0.5:4:0.5]
surface_text_depth = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module sheet_body() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

module rounded_corners() {
  union() {
    cube([sheet_length - 2*corner_radius, sheet_width, sheet_thickness], center=true);
    cube([sheet_length, sheet_width - 2*corner_radius, sheet_thickness], center=true);
    translate([sheet_length/2 - corner_radius, sheet_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=sheet_thickness, center=true);
    translate([-sheet_length/2 + corner_radius, sheet_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=sheet_thickness, center=true);
    translate([-sheet_length/2 + corner_radius, -sheet_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=sheet_thickness, center=true);
    translate([sheet_length/2 - corner_radius, -sheet_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=sheet_thickness, center=true);
  }
}

module mounting_holes() {
  union() {
    translate([sheet_length/2 - hole_edge_offset, sheet_width/2 - hole_edge_offset, 0])
      cylinder(r=hole_diameter/2, h=sheet_thickness + 2*edge_overlap, center=true);
    translate([-sheet_length/2 + hole_edge_offset, sheet_width/2 - hole_edge_offset, 0])
      cylinder(r=hole_diameter/2, h=sheet_thickness + 2*edge_overlap, center=true);
    translate([-sheet_length/2 + hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0])
      cylinder(r=hole_diameter/2, h=sheet_thickness + 2*edge_overlap, center=true);
    translate([sheet_length/2 - hole_edge_offset, -sheet_width/2 + hole_edge_offset, 0])
      cylinder(r=hole_diameter/2, h=sheet_thickness + 2*edge_overlap, center=true);
  }
}

module chamfer_edges() {
  union() {
    translate([0, sheet_width/2 - chamfer_size/2, sheet_thickness/2 - chamfer_size/2])
      cube([sheet_length + 2*edge_overlap, chamfer_size, chamfer_size], center=true);
    translate([0, -sheet_width/2 + chamfer_size/2, sheet_thickness/2 - chamfer_size/2])
      cube([sheet_length + 2*edge_overlap, chamfer_size, chamfer_size], center=true);
    translate([sheet_length/2 - chamfer_size/2, 0, sheet_thickness/2 - chamfer_size/2])
      cube([chamfer_size, sheet_width + 2*edge_overlap, chamfer_size], center=true);
    translate([-sheet_length/2 + chamfer_size/2, 0, sheet_thickness/2 - chamfer_size/2])
      cube([chamfer_size, sheet_width + 2*edge_overlap, chamfer_size], center=true);
  }
}

module fillet_edges() {
  union() {
    translate([0, sheet_width/2 - fillet_radius, sheet_thickness/2 - fillet_radius])
      rotate([0, 90, 0]) cylinder(r=fillet_radius, h=sheet_length + 2*edge_overlap, center=true);
    translate([0, -sheet_width/2 + fillet_radius, sheet_thickness/2 - fillet_radius])
      rotate([0, 90, 0]) cylinder(r=fillet_radius, h=sheet_length + 2*edge_overlap, center=true);
    translate([sheet_length/2 - fillet_radius, 0, sheet_thickness/2 - fillet_radius])
      rotate([90, 0, 0]) cylinder(r=fillet_radius, h=sheet_width + 2*edge_overlap, center=true);
    translate([-sheet_length/2 + fillet_radius, 0, sheet_thickness/2 - fillet_radius])
      rotate([90, 0, 0]) cylinder(r=fillet_radius, h=sheet_width + 2*edge_overlap, center=true);
  }
}

module surface_text() {
  translate([0, 0, sheet_thickness/2 - surface_text_depth/2])
    cube([sheet_length/3, sheet_width/5, surface_text_depth], center=true);
}

// Final Model
difference() {
  intersection() {
    sheet_body();
    rounded_corners();
  }
  mounting_holes();
  chamfer_edges();
  fillet_edges();
  surface_text();
}