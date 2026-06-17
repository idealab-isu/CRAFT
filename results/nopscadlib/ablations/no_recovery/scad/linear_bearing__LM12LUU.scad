// Parameters
bore_diameter_mm = 12; //[6:24:0.1]
outer_diameter_mm = 21; //[10.5:42:0.1]
length_mm = 57; //[28.5:114:0.1]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 10; //[5:25:0.1]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_diameter_mm = 9; //[5:18:0.1]
washer_thickness_mm = 1.2; //[0.6:3:0.1]
screw_z_offset_mm = 0; //[-20:20:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer cylindrical casing
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Through bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_diameter_mm/2 + screw_length_mm/2 - overlap_mm, 0, screw_z_offset_mm])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      
      // Washer
      translate([outer_diameter_mm/2 - overlap_mm + washer_thickness_mm/2, 0, screw_z_offset_mm])
        rotate([0, 90, 0])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          cylinder(r=screw_shank_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
      
      // Screw head
      translate([outer_diameter_mm/2 + screw_length_mm - overlap_mm + screw_head_height_mm/2, 0, screw_z_offset_mm])
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