// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 6.0; //[3.0:12.0:0.1]
width_mm = 2.5; //[1.25:5.0:0.1]
bore_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 3.0; //[1.5:6.0:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]
rim_thickness_mm = 0.6; //[0.3:1.2:0.05]
hub_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_thickness_mm = 0.25; //[0.15:0.6:0.05]
shield_radial_gap_mm = 0.15; //[0.05:0.4:0.05]
chamfer_mm = 0.25; //[0.1:0.6:0.05]
ball_diameter_mm = 0.8; //[0.4:1.4:0.05]
ball_count = 8; //[6:12:1]
ball_pitch_radius_mm = 2.1; //[1.6:2.6:0.05]
cage_ring_thickness_mm = 0.25; //[0.15:0.6:0.05]
flange_enabled = 0; //[0:1:1]
flange_extra_radius_mm = 0.4; //[0.2:1.0:0.05]
flange_width_mm = 0.5; //[0.25:1.2:0.05]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r=outer_radius_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_radius_mm - rim_thickness_mm, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_radius_mm + hub_thickness_mm, h=width_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm, h=width_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Shield or Seal Body
    difference() {
      cylinder(r=outer_radius_mm - rim_thickness_mm - shield_radial_gap_mm, h=width_mm - 2*shield_thickness_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm + hub_thickness_mm + shield_radial_gap_mm, h=width_mm - 2*shield_thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
    // Race Chamfers
    union() {
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=outer_radius_mm, r2=outer_radius_mm - chamfer_mm, h=chamfer_mm, center=true, $fn=64);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=outer_radius_mm - chamfer_mm, r2=outer_radius_mm, h=chamfer_mm, center=true, $fn=64);
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=bore_radius_mm + hub_thickness_mm, r2=bore_radius_mm + hub_thickness_mm - chamfer_mm, h=chamfer_mm, center=true, $fn=64);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=bore_radius_mm + hub_thickness_mm - chamfer_mm, r2=bore_radius_mm + hub_thickness_mm, h=chamfer_mm, center=true, $fn=64);
    }
    // Rim and Hub Steps
    union() {
      cylinder(r=outer_radius_mm - rim_thickness_mm/2, h=width_mm - 2*shield_thickness_mm, center=true, $fn=64);
      cylinder(r=bore_radius_mm + hub_thickness_mm/2, h=width_mm - 2*shield_thickness_mm, center=true, $fn=64);
    }
    // Optional Flange
    if (flange_enabled) {
      translate([0, 0, width_mm/2 - flange_width_mm/2 + eps_mm])
        cylinder(r=outer_radius_mm + flange_extra_radius_mm, h=flange_width_mm, center=true, $fn=64);
    }
  }
}

// Ball Cage Ring
module ball_cage_ring() {
  difference() {
    cylinder(r=ball_pitch_radius_mm + ball_diameter_mm/2 - eps_mm, h=cage_ring_thickness_mm, center=true, $fn=64);
    cylinder(r=ball_pitch_radius_mm - ball_diameter_mm/2 + eps_mm, h=cage_ring_thickness_mm + 2*eps_mm, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([ball_pitch_radius_mm, 0, 0])
      bearing_ball();
  }
  ball_cage_ring();
}

assembly();