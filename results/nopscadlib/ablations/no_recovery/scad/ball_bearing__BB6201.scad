// Parameters
bore_diameter_mm = 12; //[6:24:0.5]
outer_diameter_mm = 32; //[16:64:0.5]
width_mm = 10; //[5:20:0.5]
bore_radius_mm = 6; //[3:12:0.5]
outer_radius_mm = 16; //[8:32:0.5]
eps_mm = 0.8; //[0.2:2:0.1]
rim_radial_thickness_mm = 3.2; //[1.6:6.4:0.1]
hub_radial_thickness_mm = 3; //[1.5:6:0.1]
shield_thickness_mm = 0.8; //[0.4:1.6:0.1]
shield_radial_clearance_mm = 0.6; //[0.2:1.5:0.1]
ball_diameter_mm = 5; //[3:8:0.1]

// Outer Ring
module outer_ring() {
  color("Silver") difference() {
    cylinder(r=outer_radius_mm, h=width_mm, center=true);
    cylinder(r=outer_radius_mm - rim_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Ring
module inner_ring() {
  color("DimGray") difference() {
    cylinder(r=bore_radius_mm + hub_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield or Seal
module shield_or_seal() {
  color("Black") difference() {
    translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm])
      cylinder(r=outer_radius_mm - rim_radial_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
    translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm])
      cylinder(r=bore_radius_mm + hub_radial_thickness_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") translate([bore_radius_mm + hub_radial_thickness_mm + ((outer_radius_mm - rim_radial_thickness_mm) - (bore_radius_mm + hub_radial_thickness_mm))/2, 0, 0])
    sphere(r=ball_diameter_mm/2);
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