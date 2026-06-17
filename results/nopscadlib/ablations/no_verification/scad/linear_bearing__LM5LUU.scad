// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 28; //[14:56:0.5]
outer_radius_mm = 5; //[2.5:10:0.1]
inner_radius_mm = 2.5; //[1.25:5:0.1]
casing_wall_thickness_mm = 0.5; //[0.25:2:0.05]
seal_clearance_mm = 0.1; //[0.05:0.5:0.01]
seal_length_mm = 2; //[1:6:0.25]
seal_radial_thickness_mm = 0.6; //[0.2:2:0.05]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 12; //[6:30:0.5]
screw_head_diameter_mm = 5.5; //[3:10:0.1]
screw_head_height_mm = 2.5; //[1:6:0.1]
washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Outer casing
    difference() {
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      cylinder(r=outer_radius_mm - casing_wall_thickness_mm, h=length_mm + 2*overlap_mm, center=true);
      cylinder(r=inner_radius_mm, h=length_mm + 2*overlap_mm, center=true);
    }
    // End seals
    for (z = [-1, 1]) {
      translate([0, 0, z * (length_mm/2 - seal_length_mm/2 + overlap_mm)]) {
        difference() {
          cylinder(r=inner_radius_mm + seal_clearance_mm + seal_radial_thickness_mm, h=seal_length_mm, center=true);
          cylinder(r=inner_radius_mm + seal_clearance_mm, h=seal_length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw shank
    cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    // Screw head
    translate([0, 0, screw_length_mm/2 + screw_head_height_mm/2 - overlap_mm])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    // Washer
    translate([0, 0, screw_length_mm/2 - washer_thickness_mm/2 - overlap_mm]) {
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=screw_shank_diameter_mm/2 + seal_clearance_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  translate([outer_radius_mm + screw_length_mm/2 - overlap_mm, 0, 0])
    rotate([0, 90, 0]) screw_and_washer();
}

assembly();