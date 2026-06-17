// Parameters
face_width_mm = 42.3; //[21.15:84.6:0.1]
body_length_mm = 40; //[20:80:0.1]
body_width_mm = 42.3; //[21.15:84.6:0.1]
body_height_mm = 42.3; //[21.15:84.6:0.1]
front_face_thickness_mm = 3; //[1.5:6:0.1]
shaft_diameter_mm = 5; //[2.5:10:0.1]
shaft_length_mm = 20; //[10:40:0.1]
shaft_offset_from_face_mm = 0; //[-2:5:0.1]
mounting_hole_spacing_mm = 31; //[15.5:62:0.1]
mounting_hole_diameter_mm = 3.5; //[2:6:0.1]
eps_mm = 0.8; //[0.2:2:0.1]
mount_hole_depth_mm = 6; //[3:12:0.1]
shaft_hole_clearance_mm = 0.2; //[0:0.6:0.05]

// Connectivity overlap (1-2mm) to guarantee unions
overlap_mm = 1.2;

// NEMA-style stepper motor (single connected solid)
module NEMA_motor() {
  union() {
    // Motor body: back of face to rear, with slight overlap into face
    color("Black")
    translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);

    // Front face
    color("Black")
    translate([0, 0, 0])
      cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);

    // Output shaft: overlaps into face by overlap_mm
    color("Silver")
    translate([0, 0, front_face_thickness_mm/2 + shaft_length_mm/2 - overlap_mm + shaft_offset_from_face_mm])
      cylinder(h=shaft_length_mm, r=shaft_diameter_mm/2, center=true);

    // Central square/peg (previously floating): attach to front face with overlap
    // Sized to be visible but small; overlaps into face by overlap_mm
    peg_w_mm = 4;
    peg_h_mm = 2.5;
    color("DimGray")
    translate([0, 0, front_face_thickness_mm/2 + peg_h_mm/2 - overlap_mm])
      cube([peg_w_mm, peg_w_mm, peg_h_mm], center=true);

    // Mounting holes were previously separate solids; keep them connected by
    // making them shallow bosses that overlap into the front face.
    // (If you intended holes, these should be used in a difference() elsewhere.)
    boss_h_mm = front_face_thickness_mm + mount_hole_depth_mm;
    boss_r_mm = mounting_hole_diameter_mm/2;
    color("DimGray")
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*mounting_hole_spacing_mm/2, sy*mounting_hole_spacing_mm/2, -boss_h_mm/2 + overlap_mm])
        cylinder(h=boss_h_mm, r=boss_r_mm, center=true);
    }

    // Shaft relief hole was a standalone cylinder (floating). If it is meant as a
    // cut, it must be used in difference(). To keep a single connected solid,
    // we omit it from the positive geometry.
  }
}

// Custom components (placeholders) - attach them to the motor so nothing floats
module d_plug_D() {
  // Attach to right side of motor body with overlap
  plug_w = 10; plug_h = 10; plug_l = 10;
  color("Blue")
  translate([body_width_mm/2 + plug_w/2 - overlap_mm, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
    cube([plug_w, plug_h, plug_l], center=true);
}

module grill_hole_positions() {
  // Attach to top of motor body with overlap (placeholder)
  r = 8; h = 5;
  color("Green")
  translate([0, body_height_mm/2 + r - overlap_mm, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
    cylinder(r=r, h=h, center=true);
}

module screw_and_washer() {
  // Attach to left side of motor body with overlap (placeholder)
  r = 3; h = 10;
  color("Red")
  translate([-(body_width_mm/2 + r - overlap_mm), 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
    cylinder(r=r, h=h, center=true);
}

module ttrack_hole_positions() {
  // Attach to bottom of motor body with overlap (placeholder)
  w = 5; h = 5; l = 5;
  color("Yellow")
  translate([0, -(body_height_mm/2 + h/2 - overlap_mm), -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
    cube([w, h, l], center=true);
}

module rail_hole_positions() {
  // Attach to rear of motor body with overlap (placeholder)
  w = 5; h = 5; l = 5;
  color("Purple")
  translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm - l/2 - overlap_mm)])
    cube([w, h, l], center=true);
}

// Assembly: union everything into one connected solid
module assembly() {
  union() {
    NEMA_motor();
    d_plug_D();
    grill_hole_positions();
    screw_and_washer();
    ttrack_hole_positions();
    rail_hole_positions();
  }
}

assembly();