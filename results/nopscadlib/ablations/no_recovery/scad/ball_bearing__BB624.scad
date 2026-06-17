// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 13.0; //[6.5:26.0:0.1]
width_mm = 5.0; //[2.5:10.0:0.1]
bore_radius_mm = 2.0; //[1.0:4.0:0.1]
outer_radius_mm = 6.5; //[3.25:13.0:0.1]
ring_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.1]
ball_diameter_mm = 2.0; //[1.0:3.5:0.1]
ball_count = 8; //[5:14:1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Ring
    difference() {
      cylinder(r=outer_radius_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_radius_mm - ring_radial_thickness_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_radius_mm + ring_radial_thickness_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Bearing Body
    difference() {
      cylinder(r=outer_radius_mm - ring_radial_thickness_mm, h=width_mm - 2*shield_thickness_mm + 2*overlap_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm + ring_radial_thickness_mm, h=width_mm - 2*shield_thickness_mm + 4*overlap_mm, center=true, $fn=64);
    }
    // Shield or Seal
    difference() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=outer_radius_mm - ring_radial_thickness_mm + overlap_mm, h=shield_thickness_mm, center=true, $fn=64);
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=bore_radius_mm + ring_radial_thickness_mm - overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([bore_radius_mm + ring_radial_thickness_mm + (outer_radius_mm - ring_radial_thickness_mm - (bore_radius_mm + ring_radial_thickness_mm))/2, 0, 0])
          bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();