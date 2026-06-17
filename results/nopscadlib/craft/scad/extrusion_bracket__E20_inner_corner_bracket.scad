// Parameters
overall_length_x = 26; //[13:52:0.5]
overall_length_y = 25; //[12.5:50:0.5]
thickness_z = 4.7; //[2.35:9.4:0.1]
corner_angle_deg = 90; //[60:120:1]
hole_count = 2; //[1:4:1]
hole_diameter = 5; //[3:8:0.1]
hole_center_offset_from_corner = 10; //[5:20:0.5]
hole_countersink = 0; //[0:1:1]
tolerance = 0.2; //[0.05:0.5:0.05]
edge_chamfer = 0.8; //[0.2:2:0.1]
inner_corner_relief_radius = 3; //[1:8:0.5]
overlap = 1; //[0.5:2:0.1]
extrusion_size = 20; //[10:40:1]
extrusion_length = 60; //[30:120:1]

// Extrusion - complete geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    // Simplified extrusion context
    translate([-overall_length_x/2 - extrusion_length/2 + overlap, 0, -thickness_z/2 - extrusion_size/2 + overlap])
      cube([extrusion_length, extrusion_size, extrusion_size], center=true);
    translate([0, -overall_length_y/2 - extrusion_length/2 + overlap, -thickness_z/2 - extrusion_size/2 + overlap])
      cube([extrusion_size, extrusion_length, extrusion_size], center=true);
  }
}

// Extrusion Corner Bracket Assembly - complete geometry
module extrusion_corner_bracket_assembly() {
  color("Silver") {
    extrusion_inner_corner_bracket();
    extrusion();
  }
}

// Extrusion Corner Bracket Hole Positions - complete geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    translate([-overall_length_x/2 + hole_center_offset_from_corner, -overall_length_y/2 + hole_center_offset_from_corner, 0])
      cylinder(h=thickness_z + 2*overlap, r=(hole_diameter + tolerance)/2, center=true);
    translate([overall_length_x/2 - hole_center_offset_from_corner, overall_length_y/2 - hole_center_offset_from_corner, 0])
      cylinder(h=thickness_z + 2*overlap, r=(hole_diameter + tolerance)/2, center=true);
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("Silver") {
    difference() {
      cube([overall_length_x, overall_length_y, thickness_z], center=true);
      extrusion_corner_bracket_hole_positions();
      translate([-overall_length_x/2, -overall_length_y/2, 0])
        cylinder(h=thickness_z + 2*overlap, r=inner_corner_relief_radius, center=true);
      union() {
        translate([0, overall_length_y/2 - edge_chamfer/2, thickness_z/2 - edge_chamfer/2])
          rotate([45, 0, 0]) cube([overall_length_x + 2*overlap, edge_chamfer, edge_chamfer], center=true);
        translate([overall_length_x/2 - edge_chamfer/2, 0, thickness_z/2 - edge_chamfer/2])
          rotate([0, 45, 0]) cube([edge_chamfer, overall_length_y + 2*overlap, edge_chamfer], center=true);
      }
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    extrusion_inner_corner_bracket();
    extrusion();
  }
}

// Assembly
module assembly() {
  extrusion_corner_bracket_assembly();
}

assembly();