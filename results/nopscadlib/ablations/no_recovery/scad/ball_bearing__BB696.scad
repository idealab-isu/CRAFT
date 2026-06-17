// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 16; //[8:32:0.1]
width_mm = 5; //[2.5:10:0.1]
shield_type = 0; //[0:2:1]
flange = 0; //[0:1:1]
overlap_mm = 0.8; //[0.2:2:0.1]
outer_rim_radial_mm = 1.2; //[0.6:2.4:0.1]
inner_hub_radial_mm = 1.2; //[0.6:2.4:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
ball_diameter_mm = 2.4; //[1.2:4.8:0.1]
ball_count = 8; //[6:14:1]

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
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_hub_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    // Shield or Seal
    difference() {
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm + overlap_mm, h=shield_thickness_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + inner_hub_radial_mm - overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true);
    }
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
      translate([(bore_diameter_mm/2 + inner_hub_radial_mm + (outer_diameter_mm/2 - outer_rim_radial_mm))/2, 0, 0])
      bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();