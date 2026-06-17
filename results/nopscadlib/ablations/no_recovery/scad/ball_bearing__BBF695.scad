// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 13; //[6.5:26:0.1]
width_mm = 4; //[2:8:0.1]
flange_diameter_mm = 15; //[7.5:30:0.1]
flange_width_mm = 1; //[0.5:2:0.1]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
hub_thickness_mm = 1.2; //[0.6:2.4:0.1]
chamfer_mm = 0.3; //[0.1:0.8:0.05]
eps_mm = 0.8; //[0.5:2:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_gap_mm = 0.4; //[0.2:1:0.05]
ball_diameter_mm = 2; //[1:4:0.1]
ball_count = 8; //[6:14:1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - rim_thickness_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    // Flange
    translate([0, 0, width_mm/2 - flange_width_mm/2 + eps_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
    // Shield
    difference() {
      cylinder(r=outer_diameter_mm/2 - rim_thickness_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm + shield_radial_gap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
    // Chamfers
    union() {
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + hub_thickness_mm, r2=bore_diameter_mm/2 + hub_thickness_mm - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + hub_thickness_mm, r2=bore_diameter_mm/2 + hub_thickness_mm - chamfer_mm, h=chamfer_mm, center=true);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Copper") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([(bore_diameter_mm/2 + hub_thickness_mm + outer_diameter_mm/2 - rim_thickness_mm)/2, 0, 0])
        sphere(r=ball_diameter_mm/2);
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();