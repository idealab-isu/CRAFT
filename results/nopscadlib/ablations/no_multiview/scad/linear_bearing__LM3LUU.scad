// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 7.0; //[3.5:14.0:0.1]
length_mm = 19.0; //[9.5:38.0:0.5]
bore_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 3.5; //[1.75:7.0:0.05]
wall_thickness_mm = 2.0; //[1.0:4.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
seal_lip_thickness_mm = 1.0; //[0.5:2.0:0.1]
seal_lip_radial_mm = 0.4; //[0.2:1.0:0.05]
slot_enabled = 1; //[0:1:1]
slot_width_mm = 1.2; //[0.2:3.0:0.1]
slot_depth_mm = 4.0; //[1.0:8.0:0.1]
groove_enabled = 1; //[0:1:1]
groove_count = 2; //[0:4:1]
groove_width_mm = 1.2; //[0.6:3.0:0.1]
groove_depth_mm = 0.4; //[0.2:1.0:0.05]
groove_spacing_mm = 12.0; //[6.0:24.0:0.5]
screw_shank_radius_mm = 1.0; //[0.6:2.0:0.05]
screw_length_mm = 10.0; //[5.0:20.0:0.5]
screw_head_radius_mm = 2.0; //[1.2:4.0:0.1]
screw_head_height_mm = 2.0; //[1.0:4.0:0.1]
washer_outer_radius_mm = 2.8; //[1.8:5.6:0.1]
washer_thickness_mm = 0.8; //[0.4:2.0:0.1]
washer_hole_radius_mm = 1.1; //[0.7:2.2:0.05]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Outer casing
    difference() {
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      cylinder(r=bore_radius_mm, h=length_mm + 2*eps_mm, center=true);
    }
    // End seal lips
    union() {
      translate([0, 0, length_mm/2 - seal_lip_thickness_mm/2 + overlap_mm/2])
        cylinder(r=outer_radius_mm + seal_lip_radial_mm, h=seal_lip_thickness_mm, center=true);
      translate([0, 0, -length_mm/2 + seal_lip_thickness_mm/2 - overlap_mm/2])
        cylinder(r=outer_radius_mm + seal_lip_radial_mm, h=seal_lip_thickness_mm, center=true);
    }
    // Optional grooves
    if (groove_enabled) {
      for (i = [-1, 1]) {
        difference() {
          translate([0, 0, i * groove_spacing_mm/2])
            cylinder(r=outer_radius_mm + eps_mm, h=groove_width_mm, center=true);
          translate([0, 0, i * groove_spacing_mm/2])
            cylinder(r=outer_radius_mm - groove_depth_mm, h=groove_width_mm + 2*eps_mm, center=true);
        }
      }
    }
    // Optional slot
    if (slot_enabled) {
      translate([outer_radius_mm - slot_depth_mm/2 + eps_mm, 0, 0])
        rotate([0, 90, 0])
        cube([slot_depth_mm + 2*eps_mm, slot_width_mm, length_mm + 2*eps_mm], center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([outer_radius_mm + screw_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);
    // Screw head
    translate([outer_radius_mm + screw_length_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
    // Washer
    difference() {
      translate([outer_radius_mm + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_radius_mm, h=washer_thickness_mm, center=true);
      translate([outer_radius_mm + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
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