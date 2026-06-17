// Parameters
body_diameter_mm = 0.76; //[0.38:1.52:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.05]
body_height_mm = 3.5; //[1.75:7:0.05]
actuator_height_mm = 1.2; //[0.6:2.4:0.05]
actuator_diameter_mm = 0.3; //[0.15:0.6:0.01]
connect_overlap_mm = 0.6; //[0.2:1.2:0.05]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Body
    color("DimGray") {
      translate([0, 0, body_height_mm / 2])
        cylinder(r=body_diameter_mm / 2, h=body_height_mm, center=true, $fn=32);
    }
    // Actuator Lever
    color("Silver") {
      translate([0, 0, body_height_mm + actuator_height_mm / 2 - connect_overlap_mm])
        cylinder(r=actuator_diameter_mm / 2, h=actuator_height_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();