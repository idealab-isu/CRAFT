// Parameters
bore_diameter_mm = 10; //[5:20:0.1]
outer_diameter_mm = 30; //[15:60:0.1]
width_mm = 9; //[4.5:18:0.1]
bore_radius_mm = 5; //[2.5:10:0.1]
outer_radius_mm = 15; //[7.5:30:0.1]
eps_mm = 0.8; //[0.2:2:0.1]
outer_rim_radial_mm = 2.4; //[1.2:4.8:0.1]
inner_hub_radial_mm = 2.2; //[1.1:4.4:0.1]
shield_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
shield_axial_inset_mm = 0.6; //[0.2:1.5:0.1]
ball_diameter_mm = 4.5; //[2.5:7:0.1]

// Outer Ring
module outer_ring() {
  color("Silver") difference() {
    cylinder(r=outer_radius_mm, h=width_mm, center=true);
    cylinder(r=outer_radius_mm - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Ring
module inner_ring() {
  color("DimGray") difference() {
    cylinder(r=bore_radius_mm + inner_hub_radial_mm, h=width_mm, center=true);
    cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield or Seal Annulus
module shield_or_seal_annulus() {
  color("Black") difference() {
    cylinder(r=outer_radius_mm - outer_rim_radial_mm + eps_mm, h=width_mm - 2*shield_axial_inset_mm, center=true);
    cylinder(r=bore_radius_mm + inner_hub_radial_mm - eps_mm, h=width_mm - 2*shield_axial_inset_mm + 2*eps_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") translate([
    bore_radius_mm + inner_hub_radial_mm + ((outer_radius_mm - outer_rim_radial_mm) - (bore_radius_mm + inner_hub_radial_mm))/2,
    0,
    0
  ]) sphere(r=ball_diameter_mm/2);
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_ring();
    inner_ring();
    shield_or_seal_annulus();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();