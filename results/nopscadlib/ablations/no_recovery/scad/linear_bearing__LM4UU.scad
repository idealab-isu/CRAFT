// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_mm = 12.0; //[6.0:24.0:0.1]
casing_wall_thickness_mm = 0.8; //[0.4:1.6:0.05]
seal_lip_radial_thickness_mm = 0.4; //[0.2:1.0:0.05]
seal_lip_axial_length_mm = 1.2; //[0.6:3.0:0.1]
seal_lip_clearance_mm = 0.15; //[0.05:0.4:0.01]
connect_overlap_mm = 0.8; //[0.5:2.0:0.1]
screw_shank_diameter_mm = 2.0; //[1.0:4.0:0.1]
screw_length_mm = 10.0; //[5.0:20.0:0.5]
screw_head_diameter_mm = 4.0; //[2.5:8.0:0.1]
screw_head_height_mm = 1.6; //[0.8:3.5:0.1]
washer_outer_diameter_mm = 5.0; //[3.0:10.0:0.1]
washer_thickness_mm = 0.8; //[0.4:2.0:0.05]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    // Outer casing
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - casing_wall_thickness_mm, h=length_mm + 2*connect_overlap_mm, center=true);
    }
    // End seal lips
    union() {
      difference() {
        translate([0, 0, length_mm/2 - seal_lip_axial_length_mm/2])
          cylinder(r=outer_diameter_mm/2 - casing_wall_thickness_mm, h=seal_lip_axial_length_mm, center=true);
        translate([0, 0, length_mm/2 - seal_lip_axial_length_mm/2])
          cylinder(r=bore_diameter_mm/2 + seal_lip_clearance_mm, h=seal_lip_axial_length_mm + 2*connect_overlap_mm, center=true);
      }
      difference() {
        translate([0, 0, -length_mm/2 + seal_lip_axial_length_mm/2])
          cylinder(r=outer_diameter_mm/2 - casing_wall_thickness_mm, h=seal_lip_axial_length_mm, center=true);
        translate([0, 0, -length_mm/2 + seal_lip_axial_length_mm/2])
          cylinder(r=bore_diameter_mm/2 + seal_lip_clearance_mm, h=seal_lip_axial_length_mm + 2*connect_overlap_mm, center=true);
      }
    }
    // Through bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*connect_overlap_mm, center=true);
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    // Washer
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, 0])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=screw_shank_diameter_mm/2 + seal_lip_clearance_mm, h=washer_thickness_mm + 2*connect_overlap_mm, center=true);
      }
    // Screw shank
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, washer_thickness_mm/2 + screw_length_mm/2 - connect_overlap_mm])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    // Screw head
    translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, -washer_thickness_mm/2 - screw_head_height_mm/2 + connect_overlap_mm])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();