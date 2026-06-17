// Parameters
body_diameter_mm = 0.8; //[0.4:1.6:0.05]
overall_height_mm = 4.7; //[2.35:9.4:0.1]
body_height_mm = 3.5; //[1.75:7:0.1]
lever_height_mm = 1.2; //[0.6:2.4:0.05]
lever_diameter_mm = 0.3; //[0.15:0.6:0.02]
base_flange_diameter_mm = 1; //[0.5:2:0.05]
base_flange_thickness_mm = 0.2; //[0.1:0.4:0.02]
overlap_mm = 0.05; //[0.02:0.2:0.01]
toggle_tilt_deg = 15; //[0:35:1]

// Toggle switch - complete geometry
module toggle() {
  // Base flange
  color("Silver") {
    translate([0, 0, base_flange_thickness_mm / 2])
      cylinder(r=base_flange_diameter_mm / 2, h=base_flange_thickness_mm, center=true);
  }
  
  // Cylindrical body
  color("DimGray") {
    translate([0, 0, base_flange_thickness_mm + body_height_mm / 2 - overlap_mm])
      cylinder(r=body_diameter_mm / 2, h=body_height_mm, center=true);
  }
  
  // Actuator lever
  color("Black") {
    translate([0, 0, base_flange_thickness_mm + body_height_mm + lever_height_mm / 2 - overlap_mm])
      rotate([toggle_tilt_deg, 0, 0])
      cylinder(r=lever_diameter_mm / 2, h=lever_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();