// Parameters
bore_diameter_mm = 12; //[6:24:0.5]
outer_diameter_mm = 32; //[16:64:0.5]
width_mm = 10; //[5:20:0.5]
bore_radius_mm = 6; //[3:12:0.5]
outer_radius_mm = 16; //[8:32:0.5]
eps_mm = 0.6; //[0.2:2:0.1]
rim_thickness_mm = 2.2; //[1.1:4.4:0.1]
hub_thickness_mm = 2.6; //[1.3:5.2:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.1]
shield_radial_gap_mm = 0.4; //[0.2:1:0.1]
ball_diameter_mm = 5.5; //[3:8:0.1]
ball_count = 8; //[6:12:1]
ball_pitch_radius_mm = 11; //[8:14:0.1]
raceway_clearance_mm = 0.4; //[0.2:1:0.1]
chamfer_mm = 0.8; //[0.4:1.6:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - rim_thickness_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner race
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    // Shields
    difference() {
      union() {
        translate([0, 0, -width_mm/2 + shield_thickness_mm/2])
          cylinder(r=outer_diameter_mm/2 - rim_thickness_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
        translate([0, 0, width_mm/2 - shield_thickness_mm/2])
          cylinder(r=outer_diameter_mm/2 - rim_thickness_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
      }
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm + shield_radial_gap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
    // Chamfers
    union() {
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2 + eps_mm, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2 - chamfer_mm, r2=outer_diameter_mm/2 + eps_mm, h=chamfer_mm, center=true);
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + chamfer_mm, r2=bore_diameter_mm/2 - eps_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 - eps_mm, r2=bore_diameter_mm/2 + chamfer_mm, h=chamfer_mm, center=true);
    }
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
}

assembly();