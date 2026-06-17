// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 28; //[14:56:0.5]
overlap_mm = 1; //[0.5:2:0.1]
casing_thickness_mm = 1; //[0.5:3:0.1]
groove_count = 2; //[0:4:1]
groove_width_mm = 2; //[1:6:0.1]
groove_depth_mm = 0.6; //[0.2:2:0.1]
groove_spacing_mm = 18; //[8:40:0.5]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_head_diameter_mm = 5.5; //[4:10:0.1]
screw_head_height_mm = 2.5; //[1.5:6:0.1]
washer_outer_diameter_mm = 7; //[5:14:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]
screw_length_mm = 10; //[6:30:0.5]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    difference() {
      // Outer casing
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      // Through bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
      
      // Grooves
      if (groove_count >= 1) {
        for (i = [-1, 1]) {
          translate([0, 0, i * groove_spacing_mm/2])
            difference() {
              cylinder(r=outer_diameter_mm/2 + overlap_mm, h=groove_width_mm, center=true, $fn=64);
              cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_width_mm + 2*overlap_mm, center=true, $fn=64);
            }
        }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Washer
      translate([outer_diameter_mm/2 + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
      
      // Screw shank
      translate([outer_diameter_mm/2 + screw_length_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true, $fn=64);
      
      // Screw head
      translate([outer_diameter_mm/2 + screw_length_mm - overlap_mm + screw_head_height_mm/2, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();