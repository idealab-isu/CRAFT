// Parameters
body_diameter_mm = 12.6; //[6.3:25.2:0.1]
body_height_mm = 13.1; //[6.55:26.2:0.1]
centered = 1; //[0:1:1]
include_toggle_lever = 0; //[0:1:1]
face_thickness_mm = 0.6; //[0.3:1.2:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
toggle_diameter_mm = 4; //[2:8:0.1]
toggle_height_mm = 10; //[5:20:0.5]

// Toggle switch body
module switch_body() {
  color("DimGray") {
    // Main cylindrical body
    cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true);
    
    // Top face
    translate([0, 0, body_height_mm/2 - face_thickness_mm/2 - overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_diameter_mm/2, center=true);
    
    // Bottom face
    translate([0, 0, -body_height_mm/2 + face_thickness_mm/2 + overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_diameter_mm/2, center=true);
  }
}

// Toggle lever
module toggle() {
  if (include_toggle_lever) {
    color("Silver") {
      translate([0, 0, body_height_mm/2 + toggle_height_mm/2 - overlap_mm])
        cylinder(h=toggle_height_mm, r=toggle_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  switch_body();
  toggle();
}

assembly();