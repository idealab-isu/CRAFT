// Parameters
shank_diameter_mm = 3.5; //[1.75:7:0.05]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 7; //[3.5:14:0.1]
head_height_mm = 2.5; //[1.25:5:0.1]
transition_height_mm = 0.8; //[0.4:1.6:0.05]
transition_radial_mm = 0.6; //[0.3:1.2:0.05]
washer_outer_diameter_mm = 8.5; //[5:17:0.1]
washer_thickness_mm = 1; //[0.5:2:0.05]
washer_clearance_mm = 0.3; //[0.1:0.8:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shank
    translate([0, 0, -head_height_mm/2])
      cylinder(r=shank_diameter_mm/2, h=length_mm - head_height_mm, center=true);

    // Screw Head
    translate([0, 0, length_mm/2 - head_height_mm/2])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);

    // Head to Shank Transition
    translate([0, 0, length_mm/2 - head_height_mm - transition_height_mm/2 + overlap_mm/2])
      cylinder(r=shank_diameter_mm/2 + transition_radial_mm, h=transition_height_mm, center=true);

    // Washer
    difference() {
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm/2])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm/2])
        cylinder(r=shank_diameter_mm/2 + washer_clearance_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();