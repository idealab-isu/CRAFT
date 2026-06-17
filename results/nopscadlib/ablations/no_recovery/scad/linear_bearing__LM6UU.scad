// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 19; //[10:40:0.1]
bore_radius_mm = 3; //[1.5:6:0.1]
outer_radius_mm = 6; //[3:12:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1; //[0.5:2:0.1]
enable_end_seals = 1; //[0:1:1]
seal_radial_thickness_mm = 0.8; //[0.4:1.6:0.1]
seal_axial_thickness_mm = 1.2; //[0.6:2.4:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 12; //[6:30:0.5]
screw_head_diameter_mm = 5.5; //[4:10:0.1]
screw_head_height_mm = 2.5; //[1.5:5:0.1]
washer_outer_diameter_mm = 7; //[5:14:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    // Outer casing
    difference() {
      cylinder(h=length_mm, r=outer_radius_mm, center=true);
      // Inner bore
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*eps_mm, r=bore_radius_mm + eps_mm, center=true);
    }
    // End seals
    if (enable_end_seals) {
      union() {
        // Left seal
        translate([0, 0, -length_mm/2 + seal_axial_thickness_mm/2])
          difference() {
            cylinder(h=seal_axial_thickness_mm, r=bore_radius_mm + seal_radial_thickness_mm, center=true);
            cylinder(h=seal_axial_thickness_mm + 2*eps_mm, r=bore_radius_mm + eps_mm, center=true);
          }
        // Right seal
        translate([0, 0, length_mm/2 - seal_axial_thickness_mm/2])
          difference() {
            cylinder(h=seal_axial_thickness_mm, r=bore_radius_mm + seal_radial_thickness_mm, center=true);
            cylinder(h=seal_axial_thickness_mm + 2*eps_mm, r=bore_radius_mm + eps_mm, center=true);
          }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw shank
    translate([outer_radius_mm + screw_shank_diameter_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
    // Screw head
    translate([outer_radius_mm + screw_length_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
    // Washer
    translate([outer_radius_mm + screw_length_mm - washer_thickness_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + 2*eps_mm, r=screw_shank_diameter_mm/2 + eps_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();