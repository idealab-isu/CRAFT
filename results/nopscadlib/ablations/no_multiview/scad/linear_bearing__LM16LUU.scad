// Parameters
bore_diameter_mm = 16; //[8:32:0.1]
outer_diameter_mm = 28; //[14:56:0.1]
length_mm = 70; //[35:140:0.5]
casing_wall_thickness_mm = 6; //[3:12:0.1]
seal_clearance_mm = 0.2; //[0.05:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
seal_lip_length_mm = 3; //[1.5:6:0.1]
seal_lip_radial_thickness_mm = 1.2; //[0.6:2.5:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 18; //[8:40:0.5]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1.2; //[0.6:3:0.1]
screw_attachment_flat_width_mm = 10; //[6:20:0.1]
screw_attachment_flat_height_mm = 6; //[3:12:0.1]
screw_attachment_flat_thickness_mm = 2; //[1:5:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    // Outer casing
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      // Through bore
      cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }
    // End seal lips
    union() {
      translate([0, 0, length_mm/2 - seal_lip_length_mm/2 - overlap_mm])
        cylinder(h=seal_lip_length_mm, r=bore_diameter_mm/2 + seal_clearance_mm + seal_lip_radial_thickness_mm, center=true);
      translate([0, 0, -length_mm/2 + seal_lip_length_mm/2 + overlap_mm])
        cylinder(h=seal_lip_length_mm, r=bore_diameter_mm/2 + seal_clearance_mm + seal_lip_radial_thickness_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw attachment pad
    translate([outer_diameter_mm/2 + screw_attachment_flat_thickness_mm/2 - overlap_mm, 0, 0])
      cube([screw_attachment_flat_thickness_mm, screw_attachment_flat_width_mm, screw_attachment_flat_height_mm], center=true);
    // Screw shank
    translate([outer_diameter_mm/2 + screw_attachment_flat_thickness_mm + screw_length_mm/2 - 2*overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
    // Washer
    translate([outer_diameter_mm/2 + screw_attachment_flat_thickness_mm - overlap_mm + washer_thickness_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
    // Screw head
    translate([outer_diameter_mm/2 + screw_attachment_flat_thickness_mm - overlap_mm + washer_thickness_mm + screw_head_height_mm/2, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();