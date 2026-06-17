// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
length_mm = 15; //[7.5:30:0.1]
outer_radius_mm = 5; //[2.5:10:0.1]
inner_radius_mm = 2.5; //[1.25:5:0.1]
wall_thickness_mm = 2.5; //[1:5:0.1]
eps_mm = 0.5; //[0.1:2:0.1]
screw_shank_radius_mm = 1.5; //[0.75:3:0.1]
screw_length_mm = 10; //[5:20:0.1]
washer_outer_radius_mm = 4; //[2:8:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]
screw_head_radius_mm = 3; //[1.5:6:0.1]
screw_head_height_mm = 2; //[1:5:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("DimGray") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Inner bore
      translate([0, 0, -eps_mm])
        cylinder(r=bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      // Screw shank
      translate([outer_diameter_mm/2 + screw_shank_radius_mm - eps_mm, 0, 0])
        cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);
      // Washer
      translate([outer_diameter_mm/2 + washer_thickness_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=washer_outer_radius_mm, h=washer_thickness_mm, center=true);
      // Screw head
      translate([outer_diameter_mm/2 + washer_thickness_mm + screw_head_height_mm/2 - eps_mm, 0, 0])
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