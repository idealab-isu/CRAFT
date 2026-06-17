// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
width_mm = 2.5; //[1.25:5.0:0.05]
bore_radius_mm = 2.5; //[1.25:5.0:0.05]
outer_radius_mm = 4.0; //[2.0:8.0:0.05]
eps_mm = 0.6; //[0.2:1.5:0.1]
race_rim_mm = 0.7; //[0.35:1.4:0.05]
race_hub_mm = 0.6; //[0.3:1.2:0.05]
shield_thickness_mm = 0.4; //[0.2:0.8:0.05]
shield_width_mm = 1.6; //[0.8:3.2:0.05]
ball_diameter_mm = 0.9; //[0.5:1.6:0.05]
ball_count = 8; //[5:14:1]

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
      cylinder(r=outer_diameter_mm/2 - race_rim_mm, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + race_hub_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Shield or Seal Ring
    difference() {
      cylinder(r=outer_diameter_mm/2 - race_rim_mm + eps_mm, h=shield_width_mm, center=true, $fn=64);
      cylinder(r=bore_diameter_mm/2 + race_hub_mm - eps_mm, h=shield_width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count]) 
      translate([(bore_diameter_mm/2 + race_hub_mm + (outer_diameter_mm/2 - race_rim_mm))/2, 0, 0]) 
      bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();