// Parameters
bore_diameter_mm = 12.0; //[6.0:24.0:0.1]
outer_diameter_mm = 21.0; //[10.5:42.0:0.1]
length_mm = 57.0; //[28.5:114.0:0.1]
outer_radius_mm = 10.5; //[5.25:21.0:0.1]
bore_radius_mm = 6.0; //[3.0:12.0:0.1]
eps_mm = 0.5; //[0.2:2.0:0.1]
screw_shank_radius_mm = 2.0; //[1.0:4.0:0.1]
screw_length_mm = 12.0; //[6.0:24.0:0.5]
washer_outer_radius_mm = 4.5; //[2.5:9.0:0.1]
washer_thickness_mm = 1.2; //[0.6:2.4:0.1]
screw_head_radius_mm = 3.5; //[2.0:7.0:0.1]
screw_head_height_mm = 2.5; //[1.2:5.0:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_radius_mm, h=length_mm, center=true);
      // Inner bore
      cylinder(r=bore_radius_mm, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_radius_mm + screw_length_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);
      // Washer
      translate([outer_radius_mm + washer_thickness_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_radius_mm, h=washer_thickness_mm, center=true);
      // Screw head
      translate([outer_radius_mm + washer_thickness_mm + screw_head_height_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();