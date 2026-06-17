// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
width_mm = 3; //[1.5:6:0.1]
flange_diameter_mm = 9.5; //[4.75:19:0.1]
flange_width_mm = 0.5; //[0.25:1:0.05]
rim_thickness_mm = 0.8; //[0.4:1.6:0.05]
hub_thickness_mm = 0.8; //[0.4:1.6:0.05]
chamfer_mm = 0.1; //[0.05:0.3:0.01]
shield_clearance_mm = 0.25; //[0.1:0.6:0.05]
shield_thickness_mm = 0.2; //[0.1:0.5:0.05]
shield_inset_mm = 0.15; //[0.05:0.5:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.05]
ball_overlap_mm = 0.2; //[0.1:0.6:0.05]
eps_mm = 0.05; //[0.01:0.2:0.01]

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
    translate([0, 0, -width_mm/2 + flange_width_mm/2])
      difference() {
        cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm + eps_mm, h=flange_width_mm + 2*eps_mm, center=true);
      }
    // Shields
    difference() {
      translate([0, 0, width_mm/2 - shield_inset_mm - shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm - shield_clearance_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + flange_width_mm + shield_inset_mm + shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm - shield_clearance_mm, h=shield_thickness_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm + shield_clearance_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
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
    translate([(bore_diameter_mm/2 + hub_thickness_mm + (outer_diameter_mm/2 - rim_thickness_mm))/2, 0, 0])
      sphere(r=ball_diameter_mm/2);
    translate([(bore_diameter_mm/2 + hub_thickness_mm + (outer_diameter_mm/2 - rim_thickness_mm))/2, 0, 0])
      cylinder(r=ball_diameter_mm/2 - ball_overlap_mm/2, h=width_mm - 2*(shield_inset_mm + shield_thickness_mm) - eps_mm, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();