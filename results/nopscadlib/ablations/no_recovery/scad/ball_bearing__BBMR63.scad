// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 6.0; //[3.0:12.0:0.1]
width_mm = 2.5; //[1.25:5.0:0.1]
bore_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 3.0; //[1.5:6.0:0.05]
eps_mm = 0.6; //[0.2:1.5:0.1]
rim_radial_thickness_mm = 0.6; //[0.3:1.2:0.05]
hub_radial_thickness_mm = 0.5; //[0.25:1.0:0.05]
shield_thickness_mm = 0.4; //[0.2:0.8:0.05]
ball_diameter_mm = 0.8; //[0.4:1.6:0.05]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - rim_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_radial_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    // Shield or Seal
    difference() {
      cylinder(r=outer_diameter_mm/2 - rim_radial_thickness_mm + eps_mm, h=shield_thickness_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + hub_radial_thickness_mm - eps_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Copper") {
    translate([bore_diameter_mm/2 + hub_radial_thickness_mm - eps_mm, 0, 0])
      sphere(r=ball_diameter_mm/2);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();