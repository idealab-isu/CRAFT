// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 22; //[11:44:0.1]
width_mm = 7; //[3.5:14:0.1]
radial_rim_thickness_mm = 2.2; //[1.2:4.4:0.1]
radial_hub_thickness_mm = 2.0; //[1.0:4.0:0.1]
ball_diameter_mm = 3.5; //[2:6:0.1]
ball_count = 8; //[6:12:1]
shield_thickness_mm = 0.4; //[0.2:1.0:0.05]
shield_radial_clearance_mm = 0.6; //[0.2:1.5:0.05]
axial_internal_clearance_mm = 0.8; //[0.4:1.6:0.05]
overlap_mm = 0.8; //[0.3:2.0:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - radial_rim_thickness_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + radial_hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    // Shields
    for (z = [-1, 1]) {
      translate([0, 0, z * (width_mm/2 - shield_thickness_mm/2)])
        difference() {
          cylinder(r=outer_diameter_mm/2 - radial_rim_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
          cylinder(r=bore_diameter_mm/2 + radial_hub_thickness_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("DimGray") {
    sphere(r=ball_diameter_mm/2);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  // Ball Set
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i * 360/ball_count])
      translate([(bore_diameter_mm/2 + radial_hub_thickness_mm + (outer_diameter_mm/2 - radial_rim_thickness_mm))/2, 0, 0])
        bearing_ball();
  }
}

assembly();