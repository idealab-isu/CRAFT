// Parameters
body_diameter_mm = 7; //[3.5:14:0.1]
overall_height_mm = 13.6; //[6.8:27.2:0.1]
centered = 1; //[0:1:1]
include_lever = 0; //[0:1:1]
include_threads = 0; //[0:1:1]
include_nut_washer = 0; //[0:1:1]
include_pins = 0; //[0:1:1]
face_thickness_mm = 0.6; //[0.3:1.2:0.1]
face_diameter_scale = 0.96; //[0.85:1:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]
lever_diameter_mm = 2.5; //[1.5:5:0.1]
lever_height_mm = 6; //[3:12:0.1]

// Toggle switch body
module switch_body() {
  color("DimGray") {
    // Main body cylinder
    cylinder(h=overall_height_mm, r=body_diameter_mm/2, center=true);
    
    // Top face
    translate([0, 0, overall_height_mm/2 - face_thickness_mm/2 - overlap_mm/2])
      cylinder(h=face_thickness_mm, r=(body_diameter_mm*face_diameter_scale)/2, center=true);
    
    // Bottom face
    translate([0, 0, -overall_height_mm/2 + face_thickness_mm/2 + overlap_mm/2])
      cylinder(h=face_thickness_mm, r=(body_diameter_mm*face_diameter_scale)/2, center=true);
  }
}

// Toggle lever
module toggle() {
  if (include_lever) {
    color("Silver") {
      translate([0, 0, overall_height_mm/2 + (lever_height_mm*include_lever)/2 - overlap_mm])
        cylinder(h=lever_height_mm*include_lever, r=(lever_diameter_mm/2)*include_lever, center=true);
    }
  }
}

// Assembly
module assembly() {
  switch_body();
  toggle();
}

assembly();