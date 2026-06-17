// Parameters
bore_diameter_mm = 16; //[8:32:0.1]
outer_diameter_mm = 28; //[14:56:0.1]
length_mm = 37; //[18.5:74:0.1]
casing_wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
seal_ring_length_mm = 3; //[1.5:6:0.1]
seal_outer_clearance_mm = 0.2; //[0.05:0.6:0.05]
seal_inner_clearance_mm = 0.3; //[0.05:0.8:0.05]
groove_enabled = 1; //[0:1:1]
groove_count = 2; //[0:2:1]
groove_width_mm = 1.6; //[0.8:3.2:0.1]
groove_depth_mm = 0.6; //[0.3:1.2:0.05]
groove_spacing_mm = 26; //[13:52:0.1]
overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 12; //[6:24:0.1]
screw_head_diameter_mm = 7; //[3.5:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_diameter_mm = 10; //[5:20:0.1]
washer_thickness_mm = 1.2; //[0.6:2.4:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    difference() {
      // Outer casing
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
      // Inner bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
      
      // External grooves
      if (groove_enabled && groove_count > 0) {
        for (i = [0:groove_count-1]) {
          translate([0, 0, (i-0.5)*(groove_spacing_mm)]) {
            cylinder(r=outer_diameter_mm/2 - groove_depth_mm, h=groove_width_mm + 2*overlap_mm, center=true, $fn=64);
          }
        }
      }
    }
    
    // End seal rings
    for (z = [-1, 1]) {
      translate([0, 0, z*(length_mm/2 - seal_ring_length_mm/2 + overlap_mm/2)]) {
        difference() {
          cylinder(r=outer_diameter_mm/2 - casing_wall_thickness_mm - seal_outer_clearance_mm, h=seal_ring_length_mm, center=true, $fn=64);
          cylinder(r=bore_diameter_mm/2 + seal_inner_clearance_mm, h=seal_ring_length_mm + 2*overlap_mm, center=true, $fn=64);
        }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw shank
    translate([outer_diameter_mm/2 + screw_length_mm/2 - overlap_mm, 0, 0]) 
      rotate([0, 90, 0]) 
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true, $fn=32);
    
    // Screw head
    translate([outer_diameter_mm/2 - overlap_mm + screw_head_height_mm/2, 0, 0]) 
      rotate([0, 90, 0]) 
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true, $fn=32);
    
    // Washer
    translate([outer_diameter_mm/2 - overlap_mm + washer_thickness_mm/2, 0, 0]) 
      rotate([0, 90, 0]) 
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=32);
        cylinder(r=screw_shank_diameter_mm/2 + overlap_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=32);
      }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();