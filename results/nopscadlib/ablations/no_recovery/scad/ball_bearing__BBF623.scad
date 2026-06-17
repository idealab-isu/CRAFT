// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
width_mm = 4; //[2:8:0.1]
flange_diameter_mm = 11.5; //[6:23:0.1]
flange_width_mm = 0.8; //[0.4:1.6:0.05]
rim_thickness_mm = 1.2; //[0.6:2.4:0.05]
hub_thickness_mm = 1; //[0.5:2:0.05]
chamfer_mm = 0.3; //[0.1:0.8:0.05]
shield_thickness_mm = 0.3; //[0.15:0.8:0.05]
shield_radial_overlap_mm = 0.6; //[0.2:1.5:0.05]
raceway_clearance_mm = 0.35; //[0.15:0.8:0.05]
ball_diameter_mm = 1.6; //[0.8:3.2:0.05]
ball_radial_position_mm = 3.2; //[2:5:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - rim_thickness_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Flange
    difference() {
      translate([0, 0, -width_mm/2 + flange_width_mm/2])
        cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
      translate([0, 0, -width_mm/2 + flange_width_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm, h=flange_width_mm + 2*overlap_mm, center=true);
    }
    
    // Shields
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
    }
    
    // Chamfers
    difference() {
      // Outer Ring Chamfers
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_mm, h=chamfer_mm, center=true);
      
      // Inner Ring Chamfers
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + hub_thickness_mm, r2=bore_diameter_mm/2 + hub_thickness_mm - chamfer_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r1=bore_diameter_mm/2 + hub_thickness_mm, r2=bore_diameter_mm/2 + hub_thickness_mm - chamfer_mm, h=chamfer_mm, center=true);
    }
    
    // Raceway Clearance
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm + raceway_clearance_mm, h=width_mm + 2*overlap_mm, center=true);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("SteelBlue") {
    translate([ball_radial_position_mm, 0, 0])
      sphere(r=ball_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();