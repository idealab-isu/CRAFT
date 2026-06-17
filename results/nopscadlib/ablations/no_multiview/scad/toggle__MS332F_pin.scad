// Parameters
body_diameter_mm = 1.0; //[0.5:2.0:0.05]
overall_height_mm = 4.7; //[2.35:9.4:0.1]
body_height_mm = 3.7; //[1.85:7.4:0.1]
lever_height_mm = 1.0; //[0.5:2.0:0.05]
lever_diameter_mm = 0.3; //[0.15:0.6:0.01]
overlap_mm = 0.6; //[0.2:1.5:0.1]

// Toggle switch - complete geometry
module toggle() {
  union() {
    // Cylindrical body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=32);
    }
    // Toggle lever
    color("Silver") {
      translate([0, 0, body_height_mm/2 + lever_height_mm/2 - overlap_mm])
        cylinder(h=lever_height_mm, r=lever_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();