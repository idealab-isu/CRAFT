// Parameters
bore_diameter_mm = 8.0; //[4.0:16.0:0.1]
outer_diameter_mm = 22.0; //[11.0:44.0:0.1]
width_mm = 7.0; //[3.5:14.0:0.1]
bore_radius_mm = 4.0; //[2.0:8.0:0.1]
outer_radius_mm = 11.0; //[5.5:22.0:0.1]
eps_mm = 0.8; //[0.2:2.0:0.1]
outer_rim_radial_mm = 2.2; //[1.1:4.4:0.1]
inner_hub_radial_mm = 2.6; //[1.3:5.2:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_clearance_mm = 0.4; //[0.2:1.0:0.05]
ball_diameter_mm = 3.5; //[2.0:5.0:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Ring
    difference() {
      cylinder(r=outer_radius_mm, h=width_mm, center=true);
      cylinder(r=outer_radius_mm - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_radius_mm + inner_hub_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Shields
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm])
        difference() {
          cylinder(r=outer_radius_mm - outer_rim_radial_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
          cylinder(r=bore_radius_mm + inner_hub_radial_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
        }
      translate([0, 0, -(width_mm/2 - shield_thickness_mm/2 - eps_mm)])
        difference() {
          cylinder(r=outer_radius_mm - outer_rim_radial_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
          cylinder(r=bore_radius_mm + inner_hub_radial_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
        }
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Copper") {
    translate([(bore_radius_mm + inner_hub_radial_mm + (outer_radius_mm - outer_rim_radial_mm))/2, 0, 0])
      sphere(r=ball_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();