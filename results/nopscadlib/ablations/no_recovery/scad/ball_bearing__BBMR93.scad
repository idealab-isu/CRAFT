// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
width_mm = 4.0; //[2.0:8.0:0.1]
bore_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 4.5; //[2.25:9.0:0.05]
race_radial_thickness_mm = 1.0; //[0.5:2.0:0.05]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_clearance_mm = 0.2; //[0.1:0.6:0.05]
ball_diameter_mm = 1.6; //[0.8:3.2:0.05]
ball_radial_overlap_mm = 0.3; //[0.1:0.8:0.05]
eps_mm = 0.6; //[0.2:1.5:0.05]

// Outer Race
module outer_race() {
  color("Silver") difference() {
    cylinder(r=outer_radius_mm, h=width_mm, center=true);
    cylinder(r=outer_radius_mm - race_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Race
module inner_race() {
  color("Silver") difference() {
    cylinder(r=bore_radius_mm + race_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield or Seal
module shield_or_seal() {
  color("DimGray") difference() {
    cylinder(r=outer_radius_mm - race_radial_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
    cylinder(r=bore_radius_mm + race_radial_thickness_mm + shield_radial_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") translate([
    (bore_radius_mm + race_radial_thickness_mm + shield_radial_clearance_mm) + 
    (((outer_radius_mm - race_radial_thickness_mm - shield_radial_clearance_mm) - 
    (bore_radius_mm + race_radial_thickness_mm + shield_radial_clearance_mm)) / 2),
    0, 0
  ]) sphere(r=ball_diameter_mm/2);
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_race();
    inner_race();
    shield_or_seal();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();