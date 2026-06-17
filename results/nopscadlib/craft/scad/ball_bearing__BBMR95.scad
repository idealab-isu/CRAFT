// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
width_mm = 3.0; //[1.5:6.0:0.1]
bore_radius_mm = 2.5; //[1.25:5.0:0.05]
outer_radius_mm = 4.5; //[2.25:9.0:0.05]
race_radial_thickness_mm = 0.8; //[0.4:1.6:0.05]
shield_thickness_mm = 0.4; //[0.2:0.8:0.05]
shield_width_mm = 2.4; //[1.2:3.0:0.05]
ball_diameter_mm = 0.9; //[0.5:1.6:0.05]
ball_count = 8; //[6:12:1]
overlap_mm = 0.6; //[0.2:1.2:0.05]

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
      cylinder(r=outer_radius_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_radius_mm - race_radial_thickness_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_radius_mm + race_radial_thickness_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Shield Seal Annulus
    difference() {
      cylinder(r=outer_radius_mm - race_radial_thickness_mm + overlap_mm, h=shield_width_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm + race_radial_thickness_mm - overlap_mm, h=shield_width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count]) 
        translate([((bore_radius_mm + race_radial_thickness_mm) + (outer_radius_mm - race_radial_thickness_mm))/2, 0, 0])
        bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();