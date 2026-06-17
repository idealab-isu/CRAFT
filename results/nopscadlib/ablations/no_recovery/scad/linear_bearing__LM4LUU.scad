// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_mm = 23.0; //[12.0:46.0:0.5]
bore_radius_mm = 2.0; //[1.0:4.0:0.05]
outer_radius_mm = 4.0; //[2.0:8.0:0.05]
wall_thickness_mm = 2.0; //[1.0:4.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
screw_shank_radius_mm = 1.0; //[0.6:2.0:0.05]
screw_length_mm = 10.0; //[5.0:20.0:0.5]
screw_head_radius_mm = 2.0; //[1.2:4.0:0.1]
screw_head_height_mm = 2.0; //[1.0:4.0:0.1]
washer_radius_mm = 3.0; //[2.0:6.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer casing
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      // Inner bore
      cylinder(r=bore_radius_mm, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Washer
      translate([outer_radius_mm + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_radius_mm, h=washer_thickness_mm, center=true);
      // Screw shank
      translate([outer_radius_mm + screw_shank_radius_mm - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);
      // Screw head
      translate([outer_radius_mm + screw_length_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();