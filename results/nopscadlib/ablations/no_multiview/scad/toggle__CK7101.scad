// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm = 12.7; //[6.35:25.4:0.01]
centered = 1; //[0:1:1]
face_thickness_mm = 0.6; //[0.3:1.2:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
toggle_shaft_diameter_mm = 2.2; //[1.1:4.4:0.05]
toggle_shaft_height_mm = 6; //[3:12:0.1]
toggle_tip_diameter_mm = 3; //[1.5:6:0.1]
toggle_tip_height_mm = 2.5; //[1.25:5:0.1]

// Toggle switch geometry
module toggle() {
  union() {
    // Toggle Shaft
    color("Silver") translate([0, 0, body_height_mm/2 + toggle_shaft_height_mm/2 - overlap_mm])
      cylinder(r=toggle_shaft_diameter_mm/2, h=toggle_shaft_height_mm, center=true, $fn=32);
    
    // Toggle Tip
    color("Silver") translate([0, 0, body_height_mm/2 + toggle_shaft_height_mm - overlap_mm + toggle_tip_height_mm/2 - overlap_mm])
      cylinder(r=toggle_tip_diameter_mm/2, h=toggle_tip_height_mm, center=true, $fn=32);
  }
}

// Main switch body
module switch_body() {
  union() {
    // Cylindrical Body
    color("DimGray") translate([0, 0, 0])
      cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true, $fn=64);
    
    // Top Face
    color("DimGray") translate([0, 0, body_height_mm/2 - face_thickness_mm/2])
      cylinder(r=body_diameter_mm/2, h=face_thickness_mm, center=true, $fn=64);
    
    // Bottom Face
    color("DimGray") translate([0, 0, -body_height_mm/2 + face_thickness_mm/2])
      cylinder(r=body_diameter_mm/2, h=face_thickness_mm, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  switch_body();
  toggle();
}

// Final output
assembly();