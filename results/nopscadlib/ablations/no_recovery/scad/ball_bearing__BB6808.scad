// Parameters
bore_diameter_mm = 40; //[20:80:0.5]
outer_diameter_mm = 52; //[26:104:0.5]
width_mm = 7; //[3.5:14:0.1]
bore_radius_mm = 20; //[10:40:0.5]
outer_radius_mm = 26; //[13:52:0.5]
ring_radial_thickness_mm = 3; //[1.5:6:0.1]
ball_diameter_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
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
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("DimGray") {
    translate([(bore_radius_mm + ring_radial_thickness_mm) + ((outer_radius_mm - ring_radial_thickness_mm) - (bore_radius_mm + ring_radial_thickness_mm))/2, 0, 0])
      sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();