// Parameters
body_diameter_mm = 7.0; //[3.5:14.0:0.1]
body_radius_mm = 3.5; //[1.75:7.0:0.1]
overall_height_mm = 13.6; //[6.8:27.2:0.1]
face_thickness_mm = 0.8; //[0.4:1.6:0.1]
toggle_shaft_radius_mm = 1.0; //[0.5:2.0:0.1]
toggle_shaft_height_mm = 5.0; //[2.5:10.0:0.1]
toggle_tip_radius_mm = 1.4; //[0.7:2.8:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Toggle - complete geometry
module toggle() {
  union() {
    // Toggle Shaft
    color("Silver") translate([0, 0, (overall_height_mm - face_thickness_mm) / 2 + toggle_shaft_height_mm / 2 - overlap_mm])
      cylinder(r=toggle_shaft_radius_mm, h=toggle_shaft_height_mm, center=true);
    
    // Toggle Tip
    color("Silver") translate([0, 0, (overall_height_mm - face_thickness_mm) / 2 + toggle_shaft_height_mm - overlap_mm])
      sphere(r=toggle_tip_radius_mm);
  }
}

// Switch Body with Faces
module switch_body_with_faces() {
  union() {
    // Cylindrical Body
    color("DimGray") translate([0, 0, 0])
      cylinder(r=body_radius_mm, h=overall_height_mm - 2 * face_thickness_mm, center=true);
    
    // Top Face
    translate([0, 0, (overall_height_mm - face_thickness_mm) / 2 - overlap_mm / 2])
      cylinder(r=body_radius_mm, h=face_thickness_mm, center=true);
    
    // Bottom Face
    translate([0, 0, -(overall_height_mm - face_thickness_mm) / 2 + overlap_mm / 2])
      cylinder(r=body_radius_mm, h=face_thickness_mm, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    switch_body_with_faces();
    toggle();
  }
}

assembly();