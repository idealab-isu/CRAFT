// Parameters
socket_style_old = 1; //[0:1:1]
switched = 0; //[0:1:1]
include_earth_terminal_position = 1; //[0:1:1]
include_panel_cutout = 0; //[0:1:1]
plate_width = 86; //[60:172:1]
plate_height = 86; //[60:172:1]
plate_thickness = 3; //[2:6:1]
body_depth = 28; //[18:56:1]
body_wall = 2.5; //[1.5:5:0.5]
body_width = 70; //[50:120:1]
body_height = 70; //[50:120:1]
overlap = 1; //[0.5:2:0.5]
pin_aperture_depth = 8; //[5:16:1]
live_neutral_pitch = 22.2; //[18:28:0.1]
ln_y_offset = -11.1; //[-16:-6:0.1]
earth_y_offset = 11.1; //[6:16:0.1]
ln_slot_x = 7; //[5:10:0.5]
ln_slot_y = 4.5; //[3:7:0.5]
earth_slot_x = 4.5; //[3:7:0.5]
earth_slot_y = 8.5; //[6:12:0.5]
mount_screw_pitch = 60.3; //[45:120:0.1]
mount_screw_clear_d = 3.6; //[3:5:0.1]
countersink_top_d = 8; //[6:12:0.5]
countersink_depth = 2; //[1:4:0.5]
counterbore_d = 7; //[5:12:0.5]
counterbore_depth = 1; //[0.5:3:0.5]
earth_terminal_inset = 8; //[5:16:0.5]
earth_terminal_boss_d = 6; //[4:12:0.5]
earth_terminal_boss_h = 2; //[1:5:0.5]

// Old styling cues
plate_corner_r = 4;          // rounded corners
plate_edge_chamfer = 0.9;    // subtle chamfer
recess_depth = 0.8;          // recessed face around apertures
recess_margin = 10;          // inset from plate edge
recess_corner_r = 3;

$fn = 64;

// ---------- helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rounded_plate(w, h, t, r, chamfer) {
  // Chamfered/rounded plate via two-layer hull (old look)
  t2 = max(0.01, t - chamfer);
  hull() {
    translate([0,0,-t/2]) linear_extrude(height=0.01) rounded_rect_2d(w, h, r);
    translate([0,0,-t/2 + chamfer]) linear_extrude(height=t2) rounded_rect_2d(w - 2*chamfer, h - 2*chamfer, max(0, r - chamfer));
  }
}

module socket_body_block() {
  // Body connected to plate with overlap
  translate([0, 0, -(plate_thickness/2 + body_depth/2 - overlap)])
    cube([body_width, body_height, body_depth], center=true);
}

module earth_terminal_boss() {
  // Boss is part of the solid (not subtracted) and placed on back face of body
  translate([
      -body_width/2 + earth_terminal_inset,
      -body_height/2 + earth_terminal_inset,
      -(plate_thickness/2 + body_depth - overlap) + earth_terminal_boss_h/2
    ])
    cylinder(r=earth_terminal_boss_d/2, h=earth_terminal_boss_h, center=true);
}

// UK-style pin apertures (old unswitched): add recognizable keyhole/slot geometry
module uk_pin_apertures() {
  // Cut from front face into body
  z_pin = plate_thickness/2 - pin_aperture_depth/2 + overlap;

  // Slot end radii (capsule slots)
  ln_r = ln_slot_y/2;
  e_r  = earth_slot_x/2;

  // Small round "key" at top of each L/N slot (old look)
  ln_key_d = min(ln_slot_x, ln_slot_y) * 0.75;

  // Earth: vertical capsule
  translate([0, earth_y_offset, z_pin])
    hull() {
      translate([0,  earth_slot_y/2 - e_r, 0])
        cylinder(r=e_r, h=pin_aperture_depth + 2*overlap, center=true);
      translate([0, -earth_slot_y/2 + e_r, 0])
        cylinder(r=e_r, h=pin_aperture_depth + 2*overlap, center=true);
    }

  // Live/Neutral: horizontal capsules + small round key above each
  for (sx = [-1, 1]) {
    x0 = sx * live_neutral_pitch/2;

    translate([x0, ln_y_offset, z_pin])
      hull() {
        translate([ ln_slot_x/2 - ln_r, 0, 0])
          cylinder(r=ln_r, h=pin_aperture_depth + 2*overlap, center=true);
        translate([-ln_slot_x/2 + ln_r, 0, 0])
          cylinder(r=ln_r, h=pin_aperture_depth + 2*overlap, center=true);
      }

    // Key circle slightly above the slot (still within the recessed area)
    translate([x0, ln_y_offset + ln_slot_y/2 + ln_key_d*0.55, z_pin])
      cylinder(r=ln_key_d/2, h=pin_aperture_depth + 2*overlap, center=true);
  }
}

// ---------- main solid ----------
module mains_socket_solid() {
  union() {
    // Faceplate (old style: rounded + chamfer)
    rounded_plate(plate_width, plate_height, plate_thickness, plate_corner_r, plate_edge_chamfer);

    // Socket body
    socket_body_block();

    // Earth terminal boss (kept as part of the solid so model remains one connected solid)
    if (include_earth_terminal_position)
      earth_terminal_boss();
  }
}

// ---------- cutouts ----------
module mains_socket_cutouts() {
  union() {
    // Rear cavity (hollow inside body) - ensure it stays within body and doesn't eat the plate
    translate([0, 0, -(plate_thickness/2 + body_depth/2 - overlap) - body_wall/2])
      cube([body_width - 2*body_wall, body_height - 2*body_wall, body_depth - body_wall], center=true);

    // Recessed face (old styling)
    translate([0, 0, plate_thickness/2 - recess_depth/2 + overlap])
      linear_extrude(height=recess_depth + 2*overlap, center=true)
        rounded_rect_2d(plate_width - 2*recess_margin, plate_height - 2*recess_margin, recess_corner_r);

    // Pin apertures (recognizable UK-style)
    uk_pin_apertures();

    // Mounting screw through-holes (through plate + body)
    h_through = plate_thickness + body_depth + 4*overlap;
    z_through = -(body_depth/2 - overlap); // centered so it spans both plate and body

    for (sy = [-1, 1]) {
      translate([0, sy*mount_screw_pitch/2, z_through])
        cylinder(r=mount_screw_clear_d/2, h=h_through, center=true);

      // Countersink on front face (conical)
      translate([0, sy*mount_screw_pitch/2, plate_thickness/2 - countersink_depth/2 + overlap])
        cylinder(r1=countersink_top_d/2, r2=mount_screw_clear_d/2, h=countersink_depth + 2*overlap, center=true);

      // Counterbore (shallow) on front face
      translate([0, sy*mount_screw_pitch/2, plate_thickness/2 - counterbore_depth/2 + overlap])
        cylinder(r=counterbore_d/2, h=counterbore_depth + 2*overlap, center=true);
    }
  }
}

// ---------- assembly ----------
module assembly() {
  // One connected solid: all positive geometry is unioned, then cutouts subtracted.
  difference() {
    mains_socket_solid();
    mains_socket_cutouts();
  }
}

assembly();