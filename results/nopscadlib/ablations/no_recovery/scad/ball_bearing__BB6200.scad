// Parameters
bore_diameter_mm = 10; //[5:20:0.5]
outer_diameter_mm = 30; //[15:60:0.5]
width_mm = 9; //[4.5:18:0.5]
eps_mm = 0.6; //[0.2:2:0.1]
race_radial_thickness_mm = 3; //[1.5:6:0.25]
ball_diameter_mm = 4; //[2:8:0.25]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer body with through bore
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Outer race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm, h=width_mm, center=true, $fn=64);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("DimGray") {
    translate([
      bore_diameter_mm/2 + race_radial_thickness_mm + 
      (outer_diameter_mm/2 - race_radial_thickness_mm - 
      (bore_diameter_mm/2 + race_radial_thickness_mm))/2, 
      0, 
      0
    ])
    sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Inner Race - complete geometry
module inner_race() {
  color("Silver") {
    difference() {
      cylinder(r=bore_diameter_mm/2 + race_radial_thickness_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
  inner_race();
  bearing_ball();
}

assembly();