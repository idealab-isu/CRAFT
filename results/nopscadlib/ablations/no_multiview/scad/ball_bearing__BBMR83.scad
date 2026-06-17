// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
width_mm = 3; //[1.5:6:0.1]
ring_radial_thickness_mm = 1; //[0.6:2:0.05]
ball_diameter_mm = 1.2; //[0.6:2:0.05]
ball_count = 8; //[5:14:1]
ball_radial_clearance_mm = 0.15; //[0.05:0.4:0.01]
z_clearance_mm = 0.2; //[0.05:0.6:0.01]
overlap_mm = 0.8; //[0.3:1.5:0.05]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - ring_radial_thickness_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + ring_radial_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    // Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
      translate([bore_diameter_mm/2 + ring_radial_thickness_mm + ball_radial_clearance_mm + ball_diameter_mm/2, 0, 0])
      bearing_ball();
    }
    // Connector Web
    cylinder(r=bore_diameter_mm/2 + ring_radial_thickness_mm + overlap_mm, h=width_mm - 2*z_clearance_mm, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();