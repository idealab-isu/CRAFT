// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 16; //[8:32:0.1]
width_mm = 5; //[2.5:10:0.1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_width_mm = 1; //[0.5:3:0.1]
outer_rim_radial_mm = 1.2; //[0.6:2.4:0.1]
inner_hub_radial_mm = 1.2; //[0.6:2.4:0.1]
race_chamfer_mm = 0.4; //[0.2:1:0.05]
ball_diameter_mm = 2.0; //[1.2:3.5:0.1]
ball_count = 8; //[6:14:1]
ball_track_radius_mm = 5.2; //[3.5:7.5:0.1]
eps_mm = 0.6; //[0.2:1.5:0.1]

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
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
    }
    
    // Inner race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_hub_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    
    // Flange
    translate([0, 0, width_mm/2 - flange_width_mm/2 + eps_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
    
    // Chamfers
    union() {
      translate([0, 0, width_mm/2 - race_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - race_chamfer_mm, h=race_chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + race_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - race_chamfer_mm, h=race_chamfer_mm, center=true);
      translate([0, 0, width_mm/2 - race_chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + inner_hub_radial_mm, r2=bore_diameter_mm/2 + inner_hub_radial_mm - race_chamfer_mm, h=race_chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + race_chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + inner_hub_radial_mm, r2=bore_diameter_mm/2 + inner_hub_radial_mm - race_chamfer_mm, h=race_chamfer_mm, center=true);
    }
  }
  
  // Bearing Balls
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([ball_track_radius_mm, 0, 0])
        bearing_ball();
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();