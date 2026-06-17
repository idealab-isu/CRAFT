// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 26.5; //[13.25:53.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
mounting_hole_spacing = 31.0; //[15.5:62.0:0.1]
mounting_hole_diameter = 3.2; //[1.6:6.4:0.1]
shaft_boss_diameter = 22.0; //[11.0:44.0:0.1]
shaft_boss_height = 2.0; //[1.0:4.0:0.1]
front_face_recess_diameter = 24.0; //[12.0:48.0:0.1]
front_face_recess_depth = 0.8; //[0.0:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
pattern_stub_size = 6.0; //[3.0:12.0:0.1]
pattern_stub_depth = 1.5; //[0.8:3.0:0.1]
d_plug_length = 12.0; //[6.0:24.0:0.1]
d_plug_width = 8.0; //[4.0:16.0:0.1]
d_plug_rad = 1.5; //[0.8:3.0:0.1]
screw_shank_diameter = 3.0; //[1.5:6.0:0.1]
screw_length = 10.0; //[5.0:20.0:0.1]
screw_head_diameter = 5.5; //[2.75:11.0:0.1]
screw_head_height = 2.0; //[1.0:4.0:0.1]
washer_outer_diameter = 7.0; //[3.5:14.0:0.1]
washer_thickness = 1.0; //[0.5:2.0:0.1]

// ---------- Derived Z reference planes (centered at origin) ----------
z_face_center = 0;
z_face_front  = z_face_center + face_thickness/2;
z_face_back   = z_face_center - face_thickness/2;

z_body_center = z_face_back - body_length/2 + overlap; // slight overlap into face
z_body_front  = z_body_center + body_length/2;
z_body_back   = z_body_center - body_length/2;

// ---------- Modules for detailed components ----------
module d_plug_D() {
  // Attach to BACK of motor body (not floating)
  // Ensure it intersects the body by 'overlap'
  color("DimGray")
    translate([
      0,
      0,
      z_body_back - pattern_stub_depth/2 + overlap
    ])
      cube([d_plug_length, d_plug_width, pattern_stub_depth], center=true);
}

module grill_hole_positions() {
  // Cosmetic stub on RIGHT side, attached to body
  color("Silver")
    translate([
      body_width/2 - pattern_stub_size/2 + overlap, // push into body by overlap
      0,
      z_body_center
    ])
      cube([pattern_stub_size, pattern_stub_size, pattern_stub_depth], center=true);
}

module ttrack_hole_positions() {
  // Cosmetic stub on LEFT side, attached to body
  color("Silver")
    translate([
      -(body_width/2 - pattern_stub_size/2 + overlap), // push into body by overlap
      0,
      z_body_center
    ])
      cube([pattern_stub_size, pattern_stub_size, pattern_stub_depth], center=true);
}

module rail_hole_positions() {
  // Cosmetic stub on TOP side, attached to body
  color("Silver")
    translate([
      0,
      body_height/2 - pattern_stub_size/2 + overlap, // push into body by overlap
      z_body_center
    ])
      cube([pattern_stub_size, pattern_stub_size, pattern_stub_depth], center=true);
}

module screw_and_washer() {
  // The "small gray cylindrical/bolt-like part on the side" was floating.
  // Fix: place it on the RIGHT side of the motor body and ensure overlap into the body.
  // Keep the same general look (vertical screw with head + washer).
  color("Silver") {
    // Choose a Z location near the top of the body (as in the screenshots),
    // but still on the body (not on the front face).
    z_screw = z_body_center + body_length*0.15;

    // Place screw axis just outside the right face, then pull it into the body by overlap.
    x_screw = body_width/2 + screw_shank_diameter/2 - overlap;

    // Shank (vertical along Z)
    translate([x_screw, 0, z_screw])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);

    // Head on the +Z end of shank
    translate([x_screw, 0, z_screw + screw_length/2 + screw_head_height/2 - overlap])
      cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true);

    // Washer near the -Z end of shank
    translate([x_screw, 0, z_screw - screw_length/2 + washer_thickness/2 + overlap])
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
  }
}

// ---------- Main assembly ----------
module assembly() {
  union() {

    // Main motor solids (black)
    color("Black") union() {

      // Motor body
      translate([0, 0, z_body_center])
        cube([body_width, body_height, body_length], center=true);

      // Front face with recess and mounting holes
      difference() {
        translate([0, 0, z_face_center])
          cube([face_width, face_width, face_thickness], center=true);

        // Recess
        translate([0, 0, z_face_front - front_face_recess_depth/2])
          cylinder(r=front_face_recess_diameter/2,
                   h=front_face_recess_depth + overlap,
                   center=true);

        // Mounting holes
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * mounting_hole_spacing/2, y * mounting_hole_spacing/2, z_face_center])
            cylinder(r=mounting_hole_diameter/2,
                     h=face_thickness + overlap*2,
                     center=true);
        }
      }

      // Shaft center boss (overlaps into face)
      translate([0, 0, z_face_front + shaft_boss_height/2 - overlap])
        cylinder(r=shaft_boss_diameter/2, h=shaft_boss_height, center=true);

      // Output shaft (overlaps into boss)
      translate([0, 0, z_face_front + shaft_boss_height - overlap + shaft_length/2])
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
    }

    // Secondary components (all unioned so nothing floats)
    d_plug_D();
    grill_hole_positions();
    ttrack_hole_positions();
    rail_hole_positions();
    screw_and_washer();
  }
}

assembly();