// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 16; //[8:32:0.1]
width_mm = 5; //[2.5:10:0.1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_width_mm = 1; //[0.5:3:0.1]
rim_radial_mm = 1.6; //[0.8:3.2:0.1]
hub_radial_mm = 1.2; //[0.6:2.4:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_gap_mm = 0.3; //[0.1:0.8:0.05]
chamfer_mm = 0.4; //[0.2:1:0.05]
ball_diameter_mm = 2.5; //[1.5:4:0.1]
ball_radial_position_mm = 5.2; //[3.5:7:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - rim_radial_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    // Inner race
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    // Flange
    translate([0, 0, width_mm/2 + flange_width_mm/2 - overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
    // Shields
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - overlap_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_radial_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + overlap_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_radial_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
    }
    // Chamfers
    union() {
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2 - chamfer_mm, r2=outer_diameter_mm/2, h=chamfer_mm, center=true);
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + chamfer_mm, r2=bore_diameter_mm/2, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2, r2=bore_diameter_mm/2 + chamfer_mm, h=chamfer_mm, center=true);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("SteelBlue") {
    // Ball
    translate([ball_radial_position_mm, 0, 0])
      sphere(r=ball_diameter_mm/2, center=true);
    // Bridge
    translate([(ball_radial_position_mm - (ball_radial_position_mm + ball_diameter_mm - overlap_mm)/2), 0, 0])
      rotate([0, 90, 0])
        cylinder(r=ball_diameter_mm/2, h=ball_radial_position_mm + ball_diameter_mm - overlap_mm, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();