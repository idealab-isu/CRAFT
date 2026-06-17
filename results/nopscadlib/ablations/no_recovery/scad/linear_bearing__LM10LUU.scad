// Parameters
bore_diameter_mm = 10; //[5:20:0.1]
outer_diameter_mm = 19; //[10:38:0.1]
length_mm = 55; //[30:110:0.5]
overlap_mm = 1; //[0.5:2:0.1]
seal_lip_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
seal_lip_axial_length_mm = 2.5; //[1.5:5:0.1]
seal_lip_bore_clearance_mm = 0.3; //[0.1:0.8:0.05]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 20; //[10:40:0.5]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1.5; //[0.8:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    // Outer body
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      // Through bore
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }
    // End seal lips
    for (z = [-1, 1]) {
      translate([0, 0, z * (length_mm/2 - seal_lip_axial_length_mm/2 + overlap_mm)]) {
        difference() {
          cylinder(h=seal_lip_axial_length_mm, r=bore_diameter_mm/2 + seal_lip_bore_clearance_mm + seal_lip_radial_thickness_mm, center=true);
          cylinder(h=seal_lip_axial_length_mm + 2*overlap_mm, r=bore_diameter_mm/2 + seal_lip_bore_clearance_mm, center=true);
        }
      }
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([outer_diameter_mm/2 + screw_shank_diameter_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
    // Screw head
    translate([outer_diameter_mm/2 + screw_length_mm + screw_head_height_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
    // Washer
    difference() {
      translate([outer_diameter_mm/2 + screw_length_mm - washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([outer_diameter_mm/2 + screw_length_mm - washer_thickness_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=screw_shank_diameter_mm/2 + overlap_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();