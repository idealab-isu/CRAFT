// Parameters
bore_diameter_mm = 10; //[5:20:0.5]
outer_diameter_mm = 19; //[10:38:0.5]
length_mm = 55; //[30:110:1]
casing_thickness_mm = 1.9; //[0.8:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.5]
screw_head_diameter_mm = 7; //[4:14:0.5]
screw_head_height_mm = 3; //[1.5:6:0.5]
washer_outer_diameter_mm = 10; //[6:20:0.5]
washer_thickness_mm = 1.5; //[0.8:3:0.1]
screw_shank_length_mm = 8; //[4:20:1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer casing
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Inner casing cut
      cylinder(r=outer_diameter_mm/2 - casing_thickness_mm, h=length_mm + 2*overlap_mm, center=true);
      // Inner bore cut
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_diameter_mm/2 + screw_shank_length_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_shank_length_mm, center=true);
      // Washer
      translate([outer_diameter_mm/2 + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      // Screw head
      translate([outer_diameter_mm/2 + washer_thickness_mm - overlap_mm + screw_head_height_mm/2, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();