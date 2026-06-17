// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 7; //[3.5:14:0.1]
length_mm = 10; //[5:20:0.1]
centered = 1; //[0:1:1]
wall_thickness_mm = 2; //[1:4:0.1]
eps_mm = 0.6; //[0.2:2:0.1]
screw_shank_diameter_mm = 2.6; //[1.5:3.2:0.1]
screw_head_diameter_mm = 5.2; //[3.5:8:0.1]
screw_head_height_mm = 2.2; //[1:4:0.1]
washer_outer_diameter_mm = 6.5; //[4:10:0.1]
washer_thickness_mm = 0.8; //[0.4:2:0.1]
screw_length_mm = 16; //[10:30:0.5]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer body
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Through bore
      cylinder(r=bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw shank
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      // Screw head
      translate([0, 0, screw_length_mm/2 - screw_head_height_mm/2])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
      // Washer
      translate([0, 0, screw_length_mm/2 - screw_head_height_mm - washer_thickness_mm/2 + eps_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  linear_bearing();
  screw_and_washer();
}

assembly();