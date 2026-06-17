// Parameters
bore_diameter_mm = 40; //[20:80:0.5]
outer_diameter_mm = 52; //[26:104:0.5]
width_mm = 7; //[3.5:14:0.1]
inner_radius_mm = 20; //[10:40:0.5]
outer_radius_mm = 26; //[13:52:0.5]
radial_clearance_mm = 1.5; //[0.5:3:0.1]
ring_wall_mm = 2; //[1:4:0.1]
ball_diameter_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Inner Ring
module inner_ring() {
  difference() {
    cylinder(r=bore_diameter_mm/2 + ring_wall_mm, h=width_mm, center=true);
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Outer Ring
module outer_ring() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    cylinder(r=outer_diameter_mm/2 - ring_wall_mm, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  translate([(bore_diameter_mm/2 + ring_wall_mm) + radial_clearance_mm/2, 0, 0])
    sphere(r=ball_diameter_mm/2, center=true);
}

// Ball Bearing Assembly
module ball_bearing() {
  difference() {
    union() {
      outer_ring();
      inner_ring();
    }
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
  }
}

// Complete Assembly
module assembly() {
  color("DimGray") ball_bearing();
  color("Silver") bearing_ball();
}

assembly();