// Parameters
bore_diameter_mm = 12; //[6:24:0.1]
outer_diameter_mm = 21; //[10.5:42:0.1]
length_mm = 30; //[15:60:0.1]
wall_thickness_mm = 4.5; //[2.25:9:0.1]
inner_radius_mm = 6; //[3:12:0.05]
outer_radius_mm = 10.5; //[5.25:21:0.05]
eps_mm = 0.5; //[0.2:2:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 10; //[5:25:0.1]
screw_head_diameter_mm = 7; //[4:14:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer sleeve
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
      // Through bore
      cylinder(h=length_mm + 2*eps_mm, r=bore_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_diameter_mm/2 + screw_length_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true, $fn=32);
      
      // Screw head
      translate([outer_diameter_mm/2 + screw_length_mm + screw_head_height_mm/2 - 2*eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true, $fn=32);
      
      // Washer
      translate([outer_diameter_mm/2 + washer_thickness_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();