// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm = 12.7; //[6.35:25.4:0.01]
face_thickness_mm = 0.8; //[0.4:1.6:0.05]
face_overlap_mm = 0.8; //[0.5:2:0.05]
toggle_shaft_diameter_mm = 2.2; //[1.1:4.4:0.05]
toggle_shaft_height_mm = 8; //[4:16:0.1]
toggle_overlap_mm = 1; //[0.5:2:0.05]

// Toggle switch body
module toggle_switch_body() {
  color("DimGray") {
    // Main body cylinder
    cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true);
    
    // Top face
    translate([0, 0, body_height_mm/2 - face_thickness_mm/2 - face_overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_diameter_mm/2, center=true);
    
    // Bottom face
    translate([0, 0, -body_height_mm/2 + face_thickness_mm/2 + face_overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_diameter_mm/2, center=true);
  }
}

// Toggle lever
module toggle() {
  color("Silver") {
    translate([0, 0, body_height_mm/2 + toggle_shaft_height_mm/2 - toggle_overlap_mm])
      cylinder(h=toggle_shaft_height_mm, r=toggle_shaft_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  toggle_switch_body();
  toggle();
}

assembly();