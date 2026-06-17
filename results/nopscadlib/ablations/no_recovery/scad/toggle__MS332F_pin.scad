// Parameters
body_diameter_mm = 1.0; //[0.5:2.0:0.05]
overall_height_mm = 4.7; //[2.35:9.4:0.1]
body_height_mm = 3.5; //[1.75:7.0:0.1]
lever_height_mm = 1.2; //[0.6:2.4:0.05]
lever_diameter_mm = 0.3; //[0.15:0.6:0.01]
connection_overlap_mm = 0.6; //[0.2:1.5:0.1]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Toggle switch body
    color("DimGray") {
      translate([0, 0, body_height_mm / 2])
        cylinder(r=body_diameter_mm / 2, h=body_height_mm, center=true, $fn=32);
    }
    // Actuator lever
    color("Silver") {
      translate([0, 0, body_height_mm + lever_height_mm / 2 - connection_overlap_mm])
        cylinder(r=lever_diameter_mm / 2, h=lever_height_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();