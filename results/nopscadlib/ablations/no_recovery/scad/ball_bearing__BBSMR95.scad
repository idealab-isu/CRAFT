// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
width_mm = 2.5; //[1.25:5.0:0.05]
race_radial_thickness_mm = 0.8; //[0.4:1.6:0.05]
shield_thickness_mm = 0.3; //[0.15:0.6:0.05]
shield_radial_overlap_mm = 0.6; //[0.3:1.2:0.05]
ball_diameter_mm = 1.0; //[0.6:1.6:0.05]
ball_count = 8; //[6:12:1]
overlap_mm = 0.6; //[0.2:1.5:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + race_radial_thickness_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Shield or Seal
    difference() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - overlap_mm, h=shield_thickness_mm, center=true, $fn=64);
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=bore_diameter_mm/2 + race_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([((bore_diameter_mm/2 + race_radial_thickness_mm) + (outer_diameter_mm/2 - race_radial_thickness_mm))/2, 0, 0])
          bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();