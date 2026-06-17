// Parameters
overall_x = 26; //[13:52:0.5]
overall_y = 25; //[12.5:50:0.5]
base_thickness = 4.7; //[2.35:9.4:0.1]
intended_joint_angle_deg = 90; //[60:120:1]
hole_count = 2; //[2:2:1]
hole_diameter = 5.5; //[3:8:0.1]
hole_edge_offset = 9; //[5:18:0.5]
hole_center_from_plate_mid = 0; //[-2:2:0.1]
gusset_thickness = 3; //[1.5:6:0.1]
gusset_height = 12; //[6:24:0.5]
gusset_length = 18; //[9:36:0.5]
inside_corner_relief = 1.5; //[0:4:0.1]
overlap = 1; //[0.5:2:0.1]
extrusion_size = 20; //[10:40:1]
extrusion_length = 60; //[30:120:1]

// Extrusion - detailed geometry
module extrusion() {
  color([0.85, 0.85, 0.8]) {
    cube([extrusion_length, extrusion_size, extrusion_size], center=true);
  }
}

// Extrusion Corner Bracket Hole Positions - detailed geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    translate([hole_edge_offset, base_thickness/2 + hole_center_from_plate_mid, 0])
      rotate([90, 0, 0])
      cylinder(r=hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    translate([base_thickness/2 + hole_center_from_plate_mid, hole_edge_offset, 0])
      rotate([0, 90, 0])
      cylinder(r=hole_diameter/2, h=base_thickness + 2*overlap, center=true);
  }
}

// Extrusion Corner Bracket - detailed geometry
module extrusion_corner_bracket() {
  color("Silver") {
    difference() {
      union() {
        translate([overall_x/2, base_thickness/2, 0])
          cube([overall_x, base_thickness, overall_y], center=true);
        translate([base_thickness/2, overall_y/2, 0])
          cube([base_thickness, overall_y, overall_y], center=true);
      }
      translate([0, 0, 0])
        rotate([90, 0, 0])
        cylinder(r=inside_corner_relief, h=overall_y + 2*overlap, center=true);
    }
  }
}

// Extrusion Corner Bracket 3D - detailed geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    union() {
      extrusion_corner_bracket();
      translate([gusset_length/2, base_thickness - gusset_thickness/2, -overall_y/2 + gusset_height/2])
        cube([gusset_length, gusset_thickness, gusset_height], center=true);
      translate([base_thickness - gusset_thickness/2, gusset_length/2, -overall_y/2 + gusset_height/2])
        cube([gusset_thickness, gusset_length, gusset_height], center=true);
    }
  }
}

// Extrusion Corner Bracket Assembly - detailed geometry
module extrusion_corner_bracket_assembly() {
  color("Silver") {
    union() {
      extrusion_corner_bracket_3D();
      extrusion_corner_bracket_hole_positions();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([overall_x/2 + extrusion_length/2 - overlap, extrusion_size/2 - overlap, 0])
    extrusion_corner_bracket_assembly();
}

assembly();