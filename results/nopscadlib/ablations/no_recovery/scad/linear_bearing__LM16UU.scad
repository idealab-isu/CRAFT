// Parameters
bore_diameter_mm = 16; //[8:32:0.1]
outer_diameter_mm = 28; //[14:56:0.1]
length_mm = 37; //[18.5:74:0.1]
bore_radius_mm = 8; //[4:16:0.1]
outer_radius_mm = 14; //[7:28:0.1]
wall_thickness_mm = 6; //[3:12:0.1]
casing_inner_radius_mm = 8; //[6:13:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
groove_count = 2; //[0:2:1]
groove_width_mm = 2.2; //[1:4.5:0.1]
groove_depth_mm = 0.8; //[0.3:2:0.1]
groove_spacing_mm = 26; //[10:60:0.1]
seal_length_mm = 3; //[1.5:6:0.1]
seal_outer_radius_mm = 12.5; //[9:13.8:0.1]
seal_inner_radius_mm = 8.2; //[7.5:9:0.1]
open_bearing_enabled = 0; //[0:1:1]
open_slot_width_mm = 10; //[6:16:0.1]
open_slot_depth_mm = 20; //[10:40:0.1]
screw_shank_radius_mm = 2; //[1:4:0.1]
screw_length_mm = 20; //[10:40:0.5]
screw_head_radius_mm = 3.8; //[2.5:6:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_radius_mm = 5; //[3.5:9:0.1]
washer_thickness_mm = 1.2; //[0.6:3:0.1]
washer_hole_radius_mm = 2.2; //[1.2:4.5:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Bearing casing with grooves
    difference() {
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      cylinder(r=bore_radius_mm + eps_mm, h=length_mm + 2*eps_mm, center=true);
      if (groove_count > 0) {
        for (i = [-1, 1]) {
          translate([0, 0, i * groove_spacing_mm / 2])
            difference() {
              cylinder(r=outer_radius_mm, h=groove_width_mm + 2*eps_mm, center=true);
              cylinder(r=outer_radius_mm - groove_depth_mm, h=groove_width_mm + 4*eps_mm, center=true);
            }
        }
      }
      if (open_bearing_enabled) {
        translate([outer_radius_mm - open_slot_depth_mm/2 + overlap_mm, 0, 0])
          rotate([0, 90, 0])
          cube([open_slot_depth_mm, open_slot_width_mm, length_mm + 2*eps_mm], center=true);
      }
    }
    // End seal rings
    union() {
      for (i = [-1, 1]) {
        translate([0, 0, i * (length_mm/2 - seal_length_mm/2)])
          difference() {
            cylinder(r=seal_outer_radius_mm, h=seal_length_mm, center=true);
            cylinder(r=seal_inner_radius_mm, h=seal_length_mm + 2*eps_mm, center=true);
          }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([outer_radius_mm + screw_head_radius_mm + washer_thickness_mm + overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);
    // Screw head
    translate([outer_radius_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
    // Washer
    translate([outer_radius_mm + screw_head_height_mm + washer_thickness_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      difference() {
        cylinder(r=washer_outer_radius_mm, h=washer_thickness_mm, center=true);
        cylinder(r=washer_hole_radius_mm, h=washer_thickness_mm + 2*eps_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();