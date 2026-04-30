// Parameters
total_length = 28; //[14:56:1]
envelope_x = 28; //[14:56:1]
envelope_y = 28; //[14:56:1]
envelope_z = 20; //[10:40:1]
leg_thickness = 4; //[2:8:1]
base_plate_thickness = 4; //[2:8:1]
internal_corner_radius = 2; //[1:4:0.5]
external_edge_chamfer = 0.5; //[0:2:0.5]
grub_screw_count = 2; //[1:4:1]
grub_screw_hole_diameter = 3.3; //[2.5:5:0.1]
grub_screw_hole_depth = 8; //[4:16:1]
grub_screw_axis_offset_from_edges = 10; //[5:20:1]
grub_screw_boss_diameter = 10; //[6:16:0.5]
grub_screw_boss_height = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.5]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    cube([envelope_x, envelope_y, envelope_z], center=true);
  }
}

// Corner - complete geometry
module corner() {
  color("DimGray") {
    cube([envelope_x/2, envelope_y/2, envelope_z], center=true);
  }
}

// Extrusion Corner Bracket - complete geometry
module extrusion_corner_bracket() {
  color("Silver") {
    difference() {
      cube([envelope_x, envelope_y, envelope_z], center=true);
      translate([leg_thickness/2, leg_thickness/2, base_plate_thickness/2])
        cube([envelope_x - leg_thickness, envelope_y - leg_thickness, envelope_z - base_plate_thickness], center=true);
      translate([leg_thickness/2, leg_thickness/2, 0])
        cylinder(r=internal_corner_radius, h=envelope_z + 2*overlap, center=true);
    }
  }
}

// Extrusion Corner Bracket 3D - complete geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    union() {
      translate([envelope_x/2 - grub_screw_boss_height/2 + overlap, envelope_y/2 - grub_screw_axis_offset_from_edges, base_plate_thickness + (envelope_z - base_plate_thickness)/2])
        rotate([0, 90, 0])
        cylinder(r=grub_screw_boss_diameter/2, h=grub_screw_boss_height, center=true);
      translate([envelope_x/2 - grub_screw_axis_offset_from_edges, envelope_y/2 - grub_screw_boss_height/2 + overlap, base_plate_thickness + (envelope_z - base_plate_thickness)/2])
        rotate([90, 0, 0])
        cylinder(r=grub_screw_boss_diameter/2, h=grub_screw_boss_height, center=true);
    }
  }
}

// Extrusion Inner Corner Bracket - complete geometry
module extrusion_inner_corner_bracket() {
  color("Silver") {
    difference() {
      extrusion_corner_bracket();
      union() {
        translate([envelope_x/2 - grub_screw_hole_depth/2 + overlap, envelope_y/2 - grub_screw_axis_offset_from_edges, base_plate_thickness + (envelope_z - base_plate_thickness)/2])
          rotate([0, 90, 0])
          cylinder(r=grub_screw_hole_diameter/2, h=grub_screw_hole_depth + 2*overlap, center=true);
        translate([envelope_x/2 - grub_screw_axis_offset_from_edges, envelope_y/2 - grub_screw_hole_depth/2 + overlap, base_plate_thickness + (envelope_z - base_plate_thickness)/2])
          rotate([90, 0, 0])
          cylinder(r=grub_screw_hole_diameter/2, h=grub_screw_hole_depth + 2*overlap, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) extrusion();
  translate([0, 0, envelope_z/2]) corner();
  translate([0, 0, -envelope_z/2]) extrusion_inner_corner_bracket();
}

assembly();