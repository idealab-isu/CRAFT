// Parameters
width_mm = 84.5; //[42.25:169:0.1]
height_mm = 54.5; //[27.25:109:0.1]
thickness_mm = 6; //[3:12:0.1]
corner_radius_mm = 0.5; //[0:5:0.1]
front_face_thickness_mm = 0.8; //[0.2:2:0.1]
rear_face_thickness_mm = 0.8; //[0.2:2:0.1]
face_overlap_mm = 1; //[0.5:2:0.1]
display_recess_depth_mm = 0.6; //[0.2:2:0.1]
aperture_margin_x_mm = 6; //[2:15:0.1]
aperture_margin_y_mm = 5; //[2:15:0.1]
aperture_corner_radius_mm = 0.5; //[0:3:0.1]
pcb_offset_mm = 1.5; //[0:5:0.1]
mount_hole_diameter_mm = 3; //[2:6:0.1]

// Display module body
module display_module_body() {
  color([0.85, 0.85, 0.8]) {
    cube([width_mm, height_mm, thickness_mm], center=true);
  }
}

// Front face
module front_face() {
  color([0.75, 0.75, 0.77]) {
    translate([0, 0, thickness_mm/2 + front_face_thickness_mm/2 - face_overlap_mm])
      cube([width_mm, height_mm, front_face_thickness_mm], center=true);
  }
}

// Rear face reference plane
module rear_face_reference_plane() {
  color([0.75, 0.75, 0.77]) {
    translate([0, 0, -thickness_mm/2 - rear_face_thickness_mm/2 + face_overlap_mm])
      cube([width_mm, height_mm, rear_face_thickness_mm], center=true);
  }
}

// Display recess
module display() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, thickness_mm/2 + front_face_thickness_mm - display_recess_depth_mm/2 - face_overlap_mm])
      cube([width_mm - 2*aperture_margin_x_mm, height_mm - 2*aperture_margin_y_mm, display_recess_depth_mm], center=true);
  }
}

// Mod - Union of body and faces
module mod() {
  union() {
    display_module_body();
    front_face();
    rear_face_reference_plane();
  }
}

// Mod with display recess
module mod_with_display_recess() {
  difference() {
    mod();
    display();
  }
}

// Assembly
module assembly() {
  mod_with_display_recess();
}

assembly();