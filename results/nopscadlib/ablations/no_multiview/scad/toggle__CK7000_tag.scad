// Parameters
body_diameter = 0.76; //[0.38:1.52:0.01]
body_height = 3.5; //[1.75:7:0.05]
overall_height = 4.7; //[2.35:9.4:0.05]
lever_height = 1.2; //[0.6:2.4:0.05]
lever_diameter = 0.25; //[0.12:0.5:0.01]
base_flange_diameter = 1; //[0.5:2:0.05]
base_flange_thickness = 0.3; //[0.15:0.6:0.01]
connect_overlap = 0.05; //[0.02:0.2:0.01]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Base flange
    color("Silver") {
      translate([0, 0, 0])
        cylinder(r=base_flange_diameter/2, h=base_flange_thickness, center=true, $fn=32);
    }
    // Cylindrical body
    color("DimGray") {
      translate([0, 0, base_flange_thickness/2 + body_height/2 - connect_overlap])
        cylinder(r=body_diameter/2, h=body_height, center=true, $fn=32);
    }
    // Actuator lever
    color("Black") {
      translate([0, 0, base_flange_thickness/2 + body_height - connect_overlap + lever_height/2])
        cylinder(r=lever_diameter/2, h=lever_height, center=true, $fn=32);
    }
    // Toggle sphere
    color("Black") {
      translate([0, 0, base_flange_thickness/2 + body_height - connect_overlap + lever_height - connect_overlap])
        sphere(r=lever_diameter/2, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();