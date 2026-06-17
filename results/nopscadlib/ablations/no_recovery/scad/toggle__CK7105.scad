// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_radius_mm = 3.43; //[1.715:6.86:0.01]
overall_height_mm = 12.7; //[6.35:25.4:0.01]
centered = 1; //[0:1:1]
face_thickness_mm = 0.6; //[0.3:1.2:0.01]
overlap_mm = 0.8; //[0.2:2:0.01]
toggle_lever_diameter_mm = 2.5; //[1.25:5:0.01]
toggle_lever_height_mm = 8; //[4:16:0.01]

// Toggle switch - complete geometry
module toggle() {
  color("Silver") {
    // Cylindrical Body
    translate([0, 0, 0])
      cylinder(r=body_radius_mm, h=overall_height_mm, center=true, $fn=64);

    // Top Face
    translate([0, 0, overall_height_mm/2 - face_thickness_mm/2 - overlap_mm/2])
      cylinder(r=body_radius_mm, h=face_thickness_mm, center=true, $fn=64);

    // Bottom Face
    translate([0, 0, -overall_height_mm/2 + face_thickness_mm/2 + overlap_mm/2])
      cylinder(r=body_radius_mm, h=face_thickness_mm, center=true, $fn=64);

    // Toggle Lever (if enabled)
    if (include_toggle_lever) {
      translate([0, 0, overall_height_mm/2 + toggle_lever_height_mm/2 - overlap_mm])
        cylinder(r=toggle_lever_diameter_mm/2, h=toggle_lever_height_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  toggle();
}

assembly();