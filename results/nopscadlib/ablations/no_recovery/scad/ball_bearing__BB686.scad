// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 13; //[6.5:26:0.1]
width_mm = 5; //[2.5:10:0.1]
shield_type = 0; //[0:1:1]
eps_mm = 0.8; //[0.3:2:0.1]
outer_rim_radial_mm = 1.2; //[0.6:2.4:0.1]
inner_race_radial_mm = 1.2; //[0.6:2.4:0.1]
shield_thickness_mm = 0.5; //[0.3:1.2:0.1]
shield_radial_overlap_mm = 0.6; //[0.2:1.5:0.1]
ball_diameter_mm = 2.0; //[1.2:3:0.1]
ball_count = 8; //[6:12:1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_race_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    // Shields/Seals
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm/2])
        cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + eps_mm/2])
        cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
    }
  }
  // Bearing Balls
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([(bore_diameter_mm/2 + inner_race_radial_mm + (outer_diameter_mm/2 - outer_rim_radial_mm))/2, 0, 0])
        bearing_ball();
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();