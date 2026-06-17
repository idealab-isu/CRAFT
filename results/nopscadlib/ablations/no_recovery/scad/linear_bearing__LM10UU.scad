// Parameters
bore_diameter_mm = 10.0; //[5.0:20.0:0.1]
outer_diameter_mm = 19.0; //[10.0:38.0:0.1]
length_mm = 29.0; //[15.0:58.0:0.1]
casing_thickness_mm = 1.9; //[0.8:4.0:0.1]
seal_length_reduction_mm = 0.5; //[0.2:2.0:0.1]
seal_outer_scale = 1.12; //[1.02:1.3:0.01]
groove_outer_diameter_mm = 20.0; //[19.0:24.0:0.1]
groove_length_mm = 2.0; //[1.0:5.0:0.1]
groove_spacing_mm = 22.0; //[10.0:40.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
screw_shank_diameter_mm = 4.0; //[2.0:8.0:0.1]
screw_length_mm = 16.0; //[6.0:40.0:0.1]
screw_head_diameter_mm = 7.0; //[4.0:14.0:0.1]
screw_head_height_mm = 3.0; //[1.5:8.0:0.1]
washer_outer_diameter_mm = 9.0; //[5.0:18.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer body
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      // Through bore
      cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }
    // Seal ring
    intersection() {
      difference() {
        cylinder(h=length_mm, r=(bore_diameter_mm/2)*seal_outer_scale, center=true);
        cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
      }
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
    }
    // Grooves
    intersection() {
      union() {
        translate([0, 0, groove_spacing_mm/2 - length_mm/2 + groove_length_mm/2])
          cylinder(h=groove_length_mm, r=groove_outer_diameter_mm/2, center=true);
        translate([0, 0, -(groove_spacing_mm/2 - length_mm/2 + groove_length_mm/2)])
          cylinder(h=groove_length_mm, r=groove_outer_diameter_mm/2, center=true);
      }
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_diameter_mm/2 + screw_shank_diameter_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
      // Washer
      translate([outer_diameter_mm/2 + washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      // Screw head
      translate([outer_diameter_mm/2 + washer_thickness_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();