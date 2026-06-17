// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 13; //[6.5:26:0.1]
width_mm = 5; //[2.5:10:0.1]
bore_radius_mm = 3; //[1.5:6:0.1]
outer_radius_mm = 6.5; //[3.25:13:0.1]
ring_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
ring_axial_margin_mm = 0.4; //[0.2:1:0.05]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_clearance_mm = 0.25; //[0.1:0.6:0.05]
ball_diameter_mm = 2; //[1:4:0.1]
ball_count = 8; //[6:14:1]
ball_overlap_mm = 0.6; //[0.3:1.2:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Outer Ring
module outer_ring() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    cylinder(r=outer_diameter_mm/2 - ring_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Ring
module inner_ring() {
  color("Silver") difference() {
    cylinder(r=bore_diameter_mm/2 + ring_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield or Seal
module shield_or_seal() {
  color("DimGray") difference() {
    cylinder(r=outer_diameter_mm/2 - ring_radial_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
    cylinder(r=bore_diameter_mm/2 + ring_radial_thickness_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
      translate([((bore_diameter_mm/2 + ring_radial_thickness_mm) + (outer_diameter_mm/2 - ring_radial_thickness_mm))/2, 0, 0])
      sphere(r=ball_diameter_mm/2, center=true);
    }
  }
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_ring();
    inner_ring();
    translate([0, 0, (width_mm - shield_thickness_mm)/2]) shield_or_seal();
    translate([0, 0, -(width_mm - shield_thickness_mm)/2]) shield_or_seal();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();