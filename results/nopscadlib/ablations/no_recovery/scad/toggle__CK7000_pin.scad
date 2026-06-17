// Parameters
body_diameter_mm = 0.76; //[0.38:1.52:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.05]
body_height_mm = 3.5; //[1.75:7:0.05]
lever_height_mm = 1.2; //[0.6:2.4:0.05]
lever_diameter_mm = 0.3; //[0.15:0.6:0.01]
toggle_diameter_mm = 0.5; //[0.25:1:0.01]
toggle_height_mm = 0.4; //[0.2:0.8:0.01]
overlap_mm = 0.05; //[0.02:0.2:0.01]

// Toggle switch model
module toggle_switch_model() {
  union() {
    // Cylindrical body
    color("DimGray") {
      translate([0, 0, body_height_mm / 2])
        cylinder(r=body_diameter_mm / 2, h=body_height_mm, center=true);
    }
    
    // Actuator lever
    color("Silver") {
      translate([0, 0, body_height_mm + (lever_height_mm + overlap_mm) / 2 - overlap_mm])
        cylinder(r=lever_diameter_mm / 2, h=lever_height_mm + overlap_mm, center=true);
    }
    
    // Toggle cap
    color("Black") {
      translate([0, 0, body_height_mm + lever_height_mm + (toggle_height_mm + overlap_mm) / 2 - overlap_mm])
        cylinder(r=toggle_diameter_mm / 2, h=toggle_height_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  toggle_switch_model();
}

assembly();