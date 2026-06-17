// Parameters
bore_diameter_mm = 10; //[5:20:0.1]
outer_diameter_mm = 19; //[10:38:0.1]
length_mm = 29; //[15:58:0.1]
bore_radius_mm = 5; //[2.5:10:0.1]
outer_radius_mm = 9.5; //[5:19:0.1]
eps_mm = 0.5; //[0.2:2:0.1]
screw_shank_radius_mm = 2; //[1:4:0.1]
screw_head_radius_mm = 3.5; //[2:7:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_radius_mm = 4.5; //[2.5:9:0.1]
washer_thickness_mm = 1.2; //[0.6:3:0.1]
screw_length_mm = 12; //[6:24:0.5]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer casing
      cylinder(h=length_mm, r=outer_radius_mm, center=true, $fn=64);
      // Inner bore
      cylinder(h=length_mm + 2*eps_mm, r=bore_radius_mm, center=true, $fn=64);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_radius_mm + screw_shank_radius_mm - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_length_mm, r=screw_shank_radius_mm, center=true, $fn=32);
      // Washer
      translate([outer_radius_mm + washer_thickness_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm, r=washer_radius_mm, center=true, $fn=32);
      // Screw head
      translate([outer_radius_mm + washer_thickness_mm + screw_head_height_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_head_height_mm, r=screw_head_radius_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();