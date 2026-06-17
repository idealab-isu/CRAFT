// Parameters
bore_diameter_mm = 12.0; //[6.0:24.0:0.1]
outer_diameter_mm = 21.0; //[10.5:42.0:0.1]
length_mm = 30.0; //[15.0:60.0:0.1]
centered = 1; //[0:1:1]
include_grooves = 0; //[0:1:1]
groove_count = 0; //[0:2:1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
casing_wall_mm = 1.8; //[0.9:3.6:0.1]
seal_thickness_mm = 1.5; //[0.8:3.0:0.1]
seal_radial_mm = 1.2; //[0.6:2.4:0.1]
groove_depth_mm = 0.6; //[0.3:1.2:0.05]
groove_width_mm = 2.0; //[1.0:4.0:0.1]
groove_spacing_mm = 20.0; //[10.0:40.0:0.5]
screw_shank_d_mm = 4.0; //[2.0:8.0:0.1]
screw_length_mm = 16.0; //[8.0:32.0:0.5]
screw_head_d_mm = 7.0; //[4.0:14.0:0.1]
screw_head_h_mm = 3.0; //[1.5:6.0:0.1]
washer_od_mm = 10.0; //[6.0:20.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.5:0.1]
screw_mount_pad_w_mm = 8.0; //[4.0:16.0:0.1]
screw_mount_pad_h_mm = 6.0; //[3.0:12.0:0.1]
screw_mount_pad_t_mm = 4.0; //[2.0:8.0:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Outer casing
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Inner bore
      translate([0, 0, 0])
        cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }
    // End seals
    union() {
      difference() {
        translate([0, 0, -length_mm/2 + seal_thickness_mm/2 - overlap_mm/2])
          cylinder(r=bore_diameter_mm/2 + seal_radial_mm, h=seal_thickness_mm, center=true);
        translate([0, 0, -length_mm/2 + seal_thickness_mm/2 - overlap_mm/2])
          cylinder(r=bore_diameter_mm/2 + eps_mm, h=seal_thickness_mm + 2*overlap_mm, center=true);
      }
      difference() {
        translate([0, 0, length_mm/2 - seal_thickness_mm/2 + overlap_mm/2])
          cylinder(r=bore_diameter_mm/2 + seal_radial_mm, h=seal_thickness_mm, center=true);
        translate([0, 0, length_mm/2 - seal_thickness_mm/2 + overlap_mm/2])
          cylinder(r=bore_diameter_mm/2 + eps_mm, h=seal_thickness_mm + 2*overlap_mm, center=true);
      }
    }
    // Optional grooves
    if (include_grooves) {
      difference() {
        translate([0, 0, -groove_spacing_mm/2])
          cylinder(r=outer_diameter_mm/2, h=groove_width_mm, center=true);
        translate([0, 0, -groove_spacing_mm/2])
          cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_width_mm + 2*overlap_mm, center=true);
      }
      difference() {
        translate([0, 0, groove_spacing_mm/2])
          cylinder(r=outer_diameter_mm/2, h=groove_width_mm, center=true);
        translate([0, 0, groove_spacing_mm/2])
          cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_width_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color([0.4, 0.4, 0.43]) {
    // Screw mount pad
    translate([outer_diameter_mm/2 + screw_mount_pad_w_mm/2 - overlap_mm, 0, 0])
      cube([screw_mount_pad_w_mm, screw_mount_pad_t_mm, screw_mount_pad_h_mm], center=true);
    // Screw shank
    translate([outer_diameter_mm/2 + screw_mount_pad_w_mm - overlap_mm + screw_length_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_d_mm/2, h=screw_length_mm, center=true);
    // Screw head
    translate([outer_diameter_mm/2 + screw_mount_pad_w_mm - overlap_mm - screw_head_h_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_d_mm/2, h=screw_head_h_mm, center=true);
    // Washer
    difference() {
      translate([outer_diameter_mm/2 + screw_mount_pad_w_mm - overlap_mm + washer_thickness_mm/2, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_od_mm/2, h=washer_thickness_mm, center=true);
      translate([outer_diameter_mm/2 + screw_mount_pad_w_mm - overlap_mm + washer_thickness_mm/2, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_d_mm/2 + eps_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();