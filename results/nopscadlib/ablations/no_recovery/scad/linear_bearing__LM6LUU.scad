// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 35; //[18:70:0.5]
bore_radius_mm = 3; //[1.5:6:0.1]
outer_radius_mm = 6; //[3:12:0.1]
fit_clearance_mm = 0.2; //[0:0.6:0.05]
connect_overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 14; //[8:28:0.5]
washer_thickness_mm = 1.5; //[0.8:4:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 12; //[6:30:0.5]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:8:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    difference() {
      // Outer cylinder
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      // Through bore
      cylinder(h=length_mm + 2*connect_overlap_mm, r=bore_diameter_mm/2 + fit_clearance_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Washer
      translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, 0])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      
      // Screw shank
      translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, washer_thickness_mm/2 + screw_length_mm/2 - connect_overlap_mm])
        cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);
      
      // Screw head
      translate([outer_diameter_mm/2 + washer_outer_diameter_mm/2 - connect_overlap_mm, 0, washer_thickness_mm/2 + screw_length_mm - connect_overlap_mm + screw_head_height_mm/2])
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