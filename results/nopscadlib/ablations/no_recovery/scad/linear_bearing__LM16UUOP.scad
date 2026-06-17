// Parameters
bore_diameter_mm = 16; //[8:32:0.1]
outer_diameter_mm = 28; //[14:56:0.1]
length_mm = 37; //[18.5:74:0.1]
wall_thickness_mm = 1.2; //[0.6:2.4:0.1]
seal_lip_thickness_mm = 0.5; //[0.2:1.5:0.1]
seal_radial_thickness_mm = 1.0; //[0.5:2.5:0.1]
grooves_enabled = 0; //[0:1:1]
groove_depth_mm = 0; //[0:2:0.1]
groove_length_mm = 0; //[0:10:0.1]
groove_spacing_mm = 0; //[0:30:0.1]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
screw_length_mm = 16; //[8:40:0.5]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    // Outer casing
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - wall_thickness_mm, h=length_mm + 2*overlap_mm, center=true);
    }
    
    // Inner bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
    
    // End seal rings
    for (z = [-1, 1]) {
      translate([0, 0, z * (length_mm/2 - seal_lip_thickness_mm/2 + overlap_mm/2)])
        difference() {
          cylinder(r=outer_diameter_mm/2 - wall_thickness_mm, h=seal_lip_thickness_mm, center=true);
          cylinder(r=bore_diameter_mm/2 + overlap_mm, h=seal_lip_thickness_mm + 2*overlap_mm, center=true);
        }
    }
    
    // Optional grooves
    if (grooves_enabled) {
      for (z = [-groove_spacing_mm/2, groove_spacing_mm/2]) {
        translate([0, 0, z])
          cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_length_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw shank
    translate([outer_diameter_mm/2 - overlap_mm - screw_length_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    
    // Screw head
    translate([outer_diameter_mm/2 + washer_thickness_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    
    // Washer
    translate([outer_diameter_mm/2 + washer_thickness_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=screw_shank_diameter_mm/2 + overlap_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();