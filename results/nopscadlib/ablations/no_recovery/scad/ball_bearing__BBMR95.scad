// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
width_mm = 3.0; //[1.5:6.0:0.1]
bore_radius_mm = 2.5; //[1.25:5.0:0.1]
outer_radius_mm = 4.5; //[2.25:9.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
outer_ring_radial_thickness_mm = 0.9; //[0.5:1.8:0.05]
inner_ring_radial_thickness_mm = 0.7; //[0.4:1.4:0.05]
shield_thickness_mm = 0.4; //[0.2:1.0:0.05]
shield_radial_overlap_mm = 0.6; //[0.3:1.2:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.05]

// Outer Ring
module outer_ring() {
  color("Silver") difference() {
    cylinder(r=outer_radius_mm, h=width_mm, center=true);
    cylinder(r=outer_radius_mm - outer_ring_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Ring
module inner_ring() {
  color("DimGray") difference() {
    cylinder(r=bore_radius_mm + inner_ring_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield or Seal
module shield_or_seal() {
  color("Black") difference() {
    cylinder(r=outer_radius_mm - outer_ring_radial_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
    cylinder(r=bore_radius_mm + inner_ring_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") translate([bore_radius_mm + inner_ring_radial_thickness_mm + ((outer_radius_mm - outer_ring_radial_thickness_mm) - (bore_radius_mm + inner_ring_radial_thickness_mm))/2, 0, 0]) {
    sphere(r=ball_diameter_mm/2);
  }
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_ring();
    inner_ring();
    shield_or_seal();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();