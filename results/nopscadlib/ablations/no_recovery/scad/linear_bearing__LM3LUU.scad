// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 7; //[3.5:14:0.1]
length_mm = 19; //[9.5:38:0.1]
bore_radius_mm = 1.5; //[0.75:3:0.05]
outer_radius_mm = 3.5; //[1.75:7:0.05]
wall_thickness_mm = 2; //[1:4:0.1]
eps_mm = 0.8; //[0.2:2:0.1]
screw_shank_radius_mm = 1; //[0.5:2:0.1]
screw_length_mm = 10; //[5:20:0.5]
washer_radius_mm = 2.5; //[1.5:5:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer cylinder
      cylinder(h=length_mm, r=outer_radius_mm, center=true);
      // Through bore
      cylinder(h=length_mm + 2*eps_mm, r=bore_radius_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw shank
      translate([outer_radius_mm + screw_length_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_length_mm, r=screw_shank_radius_mm, center=true);
      // Washer
      translate([outer_radius_mm + washer_thickness_mm/2 - eps_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=washer_thickness_mm, r=washer_radius_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();