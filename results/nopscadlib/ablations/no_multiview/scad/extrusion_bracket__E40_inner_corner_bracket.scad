// Parameters
overall_length_a = 38; //[19:76:1]
overall_length_b = 31; //[15.5:62:1]
thickness = 8.5; //[4.25:17:0.5]
hole_count_per_face = 1; //[1:3:1]
hole_diameter = 5; //[2.5:10:0.5]
hole_edge_offset_a = 12; //[6:24:1]
hole_edge_offset_b = 12; //[6:24:1]
inside_corner_radius = 1.5; //[0.75:3:0.25]
outside_corner_radius = 2; //[1:4:0.25]
gusset_enabled = 1; //[0:1:1]
gusset_thickness = 3; //[1.5:6:0.5]
overlap = 1; //[0.5:2:0.5]
hole_extra_length = 2; //[1:6:0.5]
extrusion_size = 20; //[10:40:1]
extrusion_length = 60; //[30:120:1]
extrusion_clearance = 0.5; //[0.2:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    cube([extrusion_length, extrusion_size, extrusion_size], center=true);
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("Silver") {
    difference() {
      cube([extrusion_size - 2*extrusion_clearance, extrusion_size - 2*extrusion_clearance, thickness], center=true);
      translate([extrusion_size/2 - extrusion_clearance - overlap, extrusion_size/2 - extrusion_clearance - overlap, 0])
        cylinder(d=hole_diameter, h=thickness + hole_extra_length, center=true, $fn=32);
    }
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    union() {
      translate([overall_length_a/2, 0, 0])
        cube([overall_length_a, thickness, thickness], center=true);
      translate([0, overall_length_b/2, 0])
        cube([thickness, overall_length_b, thickness], center=true);
      if (gusset_enabled) {
        translate([thickness/2 + (overall_length_a - thickness)/2 - overlap, thickness/2 + (overall_length_b - thickness)/2 - overlap, -thickness/2 + gusset_thickness/2 + overlap])
          cube([overall_length_a - thickness, overall_length_b - thickness, gusset_thickness], center=true);
      }
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    difference() {
      extrusion_corner_bracket();
      translate([overall_length_a - hole_edge_offset_a, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=hole_diameter, h=thickness + hole_extra_length, center=true, $fn=32);
      translate([0, overall_length_b - hole_edge_offset_b, 0])
        rotate([0, 90, 0])
        cylinder(d=hole_diameter, h=thickness + hole_extra_length, center=true, $fn=32);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    union() {
      translate([overall_length_a - hole_edge_offset_a, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=hole_diameter, h=thickness + hole_extra_length, center=true, $fn=32);
      translate([0, overall_length_b - hole_edge_offset_b, 0])
        rotate([0, 90, 0])
        cylinder(d=hole_diameter, h=thickness + hole_extra_length, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([extrusion_length/2 - overlap, -(extrusion_size/2 + thickness/2 - overlap), 0])
    extrusion_inner_corner_bracket();
  translate([0, 0, 0])
    extrusion_corner_bracket_3D();
}

assembly();