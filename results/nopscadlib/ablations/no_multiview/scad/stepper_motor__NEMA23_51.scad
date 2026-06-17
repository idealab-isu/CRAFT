// Parameters
face_width_mm = 56.4; //[28.2:112.8:0.1]
body_length_mm = 51.2; //[25.6:102.4:0.1]
front_face_thickness_mm = 3.0; //[1.5:6.0:0.1]
body_width_mm = 56.4; //[28.2:112.8:0.1]
shaft_diameter_mm = 6.35; //[3.0:12.7:0.01]
shaft_length_mm = 20.0; //[10.0:40.0:0.1]
shaft_hub_diameter_mm = 22.0; //[11.0:44.0:0.1]
shaft_hub_thickness_mm = 2.5; //[1.0:6.0:0.1]
mounting_hole_spacing_mm = 47.1; //[23.55:94.2:0.1]
mounting_hole_diameter_mm = 3.5; //[2.0:6.0:0.1]
mounting_hole_cut_depth_mm = 6.0; //[3.0:15.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
d_plug_length_mm = 18.0; //[9.0:36.0:0.1]
d_plug_width_mm = 12.0; //[6.0:24.0:0.1]
d_plug_rad_mm = 2.0; //[1.0:4.0:0.1]
d_plug_thickness_mm = 3.0; //[1.5:8.0:0.1]
grill_width_mm = 30.0; //[15.0:60.0:0.1]
grill_height_mm = 30.0; //[15.0:60.0:0.1]
grill_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
grill_gap_mm = 2.0; //[1.0:6.0:0.1]
grill_thickness_mm = 1.5; //[0.8:4.0:0.1]
screw_shank_diameter_mm = 3.0; //[2.0:6.0:0.1]
screw_length_mm = 12.0; //[6.0:30.0:0.1]
screw_head_diameter_mm = 6.0; //[4.0:12.0:0.1]
screw_head_height_mm = 2.5; //[1.5:6.0:0.1]
washer_outer_diameter_mm = 7.0; //[5.0:14.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
ttrack_hole_diameter_mm = 5.0; //[3.0:10.0:0.1]
ttrack_pitch_mm = 12.0; //[6.0:24.0:0.1]
rail_hole_diameter_mm = 4.0; //[2.0:8.0:0.1]
rail_pitch_mm = 20.0; //[10.0:40.0:0.1]

// Helper: Z locations (front face centered at Z=0)
z_front_face_center = 0;
z_front_face_back   = z_front_face_center - front_face_thickness_mm/2;
z_front_face_front  = z_front_face_center + front_face_thickness_mm/2;

// D Plug D (attached to back of front face with overlap)
module d_plug_D() {
  color("DimGray")
    translate([0, 0, z_front_face_back - d_plug_thickness_mm/2 + overlap_mm])
      cube([d_plug_length_mm, d_plug_width_mm, d_plug_thickness_mm], center=true);
}

// Grill Hole Positions (kept as geometry, but now attached to back of front face)
module grill_hole_positions() {
  color("Silver") {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([
          x * (grill_width_mm/2 - grill_hole_diameter_mm/2),
          y * (grill_height_mm/2 - grill_hole_diameter_mm/2),
          z_front_face_back - grill_thickness_mm/2 + overlap_mm
        ])
          cylinder(r=grill_hole_diameter_mm/2, h=grill_thickness_mm, center=true);
  }
}

// Screw and Washer (attached to front face with overlap)
module screw_and_washer() {
  color("SteelBlue") {
    translate([
      mounting_hole_spacing_mm/2,
      mounting_hole_spacing_mm/2,
      z_front_face_front + screw_length_mm/2 - overlap_mm
    ])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);

    translate([
      mounting_hole_spacing_mm/2,
      mounting_hole_spacing_mm/2,
      z_front_face_front + screw_head_height_mm/2 - overlap_mm
    ])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);

    translate([
      mounting_hole_spacing_mm/2,
      mounting_hole_spacing_mm/2,
      z_front_face_front + washer_thickness_mm/2 - overlap_mm
    ])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
  }
}

// Ttrack Hole Positions (attached to back of front face)
module ttrack_hole_positions() {
  color("Silver") {
    for (x = [-1, 1])
      translate([x * ttrack_pitch_mm/2, 0, z_front_face_back - grill_thickness_mm/2 + overlap_mm])
        cylinder(r=ttrack_hole_diameter_mm/2, h=grill_thickness_mm, center=true);
  }
}

// Rail Hole Positions (attached to back of front face)
module rail_hole_positions() {
  color("Silver") {
    for (y = [-1, 1])
      translate([0, y * rail_pitch_mm/2, z_front_face_back - grill_thickness_mm/2 + overlap_mm])
        cylinder(r=rail_hole_diameter_mm/2, h=grill_thickness_mm, center=true);
  }
}

// FIX: Add the small blue cylindrical feature and ensure it is physically attached.
// It is placed on the top-right of the motor body and overlaps into the body by overlap_mm.
module side_cyl_feature() {
  // Size chosen to match the "small" feature appearance; kept modest and non-invasive.
  feature_d_mm = 6.0;
  feature_h_mm = 14.0;

  // Attach to +X side near +Y (top view "top-right"), running along Z.
  // Ensure intersection with body by pushing center inside by overlap_mm.
  x_center = body_width_mm/2 - feature_d_mm/2 + overlap_mm; // guarantees overlap into body
  y_center = body_width_mm/2 - feature_d_mm/2 - 2.0;        // near corner but still on the face
  z_center = z_front_face_back - body_length_mm/2 + overlap_mm; // centered on body cube

  color("SteelBlue")
    translate([x_center, y_center, z_center])
      cylinder(d=feature_d_mm, h=feature_h_mm, center=true, $fn=48);
}

// Motor Assembly
module motor_assembly() {
  color("Black") {
    // Motor Body (behind front face, overlapping by overlap_mm)
    translate([0, 0, z_front_face_back - body_length_mm/2 + overlap_mm])
      cube([body_width_mm, body_width_mm, body_length_mm], center=true);

    // Front Face
    translate([0, 0, z_front_face_center])
      cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);

    // Shaft Boss / Front Hub (in front of face, overlapping)
    translate([0, 0, z_front_face_front + shaft_hub_thickness_mm/2 - overlap_mm])
      cylinder(r=shaft_hub_diameter_mm/2, h=shaft_hub_thickness_mm, center=true);

    // Shaft (in front of face, overlapping)
    translate([0, 0, z_front_face_front + shaft_length_mm/2 - overlap_mm])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
  }
}

// Assembly (single connected solid via union; all parts overlap/touch)
module assembly() {
  union() {
    motor_assembly();
    side_cyl_feature();      // FIXED: no longer floating; overlaps into motor body
    d_plug_D();
    grill_hole_positions();
    screw_and_washer();
    ttrack_hole_positions();
    rail_hole_positions();
  }
}

assembly();