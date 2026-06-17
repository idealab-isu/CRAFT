// Parameters
body_diameter_mm = 12.6; //[6.3:25.2:0.1]
body_height_mm = 13.1; //[6.55:26.2:0.1]
centered = 1; //[0:1:1]
eps_mm = 1; //[0.5:2:0.1]
face_thickness_mm = 0.6; //[0.3:2:0.1]
toggle_shaft_diameter_mm = 3.5; //[2:7:0.1]
toggle_shaft_length_mm = 12; //[6:24:0.5]
toggle_tip_diameter_mm = 5; //[3:10:0.1]
toggle_tip_height_mm = 4; //[2:10:0.1]
toggle_angle_deg = 15; //[-30:30:1]

// Toggle switch - complete geometry
module toggle() {
  // Main body
  color("DimGray") {
    translate([0, 0, (0.5 - centered) * body_height_mm])
      cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);
  }
  
  // Top face
  color("Silver") {
    translate([0, 0, (0.5 - centered) * body_height_mm + body_height_mm/2 - face_thickness_mm/2 - eps_mm])
      cylinder(r=body_diameter_mm/2, h=face_thickness_mm, center=true);
  }
  
  // Bottom face
  color("Silver") {
    translate([0, 0, (0.5 - centered) * body_height_mm - body_height_mm/2 + face_thickness_mm/2 + eps_mm])
      cylinder(r=body_diameter_mm/2, h=face_thickness_mm, center=true);
  }
  
  // Toggle shaft
  color("Black") {
    translate([0, 0, (0.5 - centered) * body_height_mm + body_height_mm/2 + toggle_shaft_length_mm/2 - eps_mm])
      cylinder(r=toggle_shaft_diameter_mm/2, h=toggle_shaft_length_mm, center=true);
  }
  
  // Toggle tip
  color("Black") {
    translate([0, 0, (0.5 - centered) * body_height_mm + body_height_mm/2 + toggle_shaft_length_mm - eps_mm + toggle_tip_height_mm/2 - eps_mm])
      cylinder(r=toggle_tip_diameter_mm/2, h=toggle_tip_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    // Main body with faces
    union() {
      toggle();
    }
    // Rotated toggle
    rotate([toggle_angle_deg, 0, 0]) {
      union() {
        // Toggle shaft and tip
        translate([0, 0, (0.5 - centered) * body_height_mm + body_height_mm/2 + toggle_shaft_length_mm/2 - eps_mm])
          cylinder(r=toggle_shaft_diameter_mm/2, h=toggle_shaft_length_mm, center=true);
        translate([0, 0, (0.5 - centered) * body_height_mm + body_height_mm/2 + toggle_shaft_length_mm - eps_mm + toggle_tip_height_mm/2 - eps_mm])
          cylinder(r=toggle_tip_diameter_mm/2, h=toggle_tip_height_mm, center=true);
      }
    }
  }
}

assembly();