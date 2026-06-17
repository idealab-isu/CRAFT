// Parameters
body_diameter_mm = 0.76; //[0.38:1.52:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.05]
body_height_mm = 3.5; //[1.75:7:0.05]
lever_height_mm = 1.2; //[0.6:2.4:0.05]
lever_diameter_mm = 0.3; //[0.15:0.6:0.01]
base_flange_diameter_mm = 1; //[0.5:2:0.01]
base_flange_thickness_mm = 0.2; //[0.1:0.4:0.01]
overlap_mm = 0.05; //[0.02:0.2:0.01]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Cylindrical Body
    color("DimGray") {
      translate([0, 0, base_flange_thickness_mm + body_height_mm / 2])
        cylinder(r=body_diameter_mm / 2, h=body_height_mm, center=true);
    }
    // Base Flange
    color("Silver") {
      translate([0, 0, base_flange_thickness_mm / 2])
        cylinder(r=base_flange_diameter_mm / 2, h=base_flange_thickness_mm, center=true);
    }
    // Actuator Lever
    color("Black") {
      translate([0, 0, base_flange_thickness_mm + body_height_mm + lever_height_mm / 2 - overlap_mm])
        cylinder(r=lever_diameter_mm / 2, h=lever_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();