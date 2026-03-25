$fn = 64;

// Parameters
shell_width = 30; //[15:60:1]
shell_height = 12; //[6:24:1]
shell_depth = 15; //[8:30:1]
shell_wall_thickness = 1.5; //[0.8:3:0.1]
face_plate_thickness = 2; //[1:4:0.1]
flange_width = 40; //[20:80:1]
flange_height = 16; //[8:32:1]
flange_thickness = 2.5; //[1.5:5:0.1]
mount_hole_diameter = 3.2; //[2:6:0.1]
mount_hole_spacing = 33; //[20:60:1]
overlap = 1; //[0.5:2:0.1]
shell_corner_radius = 6; //[3:12:0.5]
pin_count = 9; //[5:25:1]
pin_diameter = 1; //[0.6:2:0.1]
pin_length = 4; //[2:10:0.5]
pin_pitch = 2.77; //[2:5:0.01]
jackscrew_diameter = 5; //[3:8:0.1]
jackscrew_length = 6; //[3:12:0.5]
strain_relief_diameter = 12; //[6:24:0.5]
strain_relief_length = 10; //[5:25:0.5]
cable_exit_diameter = 6; //[3:15:0.5]
cable_exit_length = 8; //[4:20:0.5]
chamfer_size = 0.8; //[0.3:2:0.1]

// D-sub specific (derived/extra)
pin_rows = 2;
row_pitch = 2.84;                 // typical D-sub row spacing
row_stagger = pin_pitch/2;        // stagger between rows
pin_recess_depth = 1.2;           // recess into face plate
face_opening_clear = 0.8;         // clearance around shell opening

// Extra details to better resemble a D-sub connector
face_recess_depth = 1.2;          // shallow recess on face around opening
face_recess_clear = 1.6;          // recess border around opening
key_flat_height = 2.2;            // height of bottom flat cut region
flange_corner_r = 2.0;            // rounded flange corners

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle 2D
module rounded_rect_2d(w, h, r) {
  rr = clamp(r, 0.01, min(w, h)/2 - 0.01);
  hull() {
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2-rr), sy*(h/2-rr)]) circle(r=rr);
  }
}

// 2D D-profile (flat bottom + rounded top) for linear_extrude
module d_profile_2d(w, h, r) {
  r2 = clamp(r, 0.01, min(w/2 - 0.01, h - 0.01));
  rect_h = max(0.01, h - r2);

  union() {
    translate([-w/2, -h/2])
      square([w, rect_h], center=false);

    translate([0, -h/2 + rect_h])
      circle(r=r2);
  }
}

// D-profile with a stronger "keying" flat at the bottom (more D-sub-like)
module d_profile_keyed_2d(w, h, r, flat_h) {
  difference() {
    d_profile_2d(w, h, r);
    // remove a thin strip at the very bottom to emphasize the flat
    translate([-w/2 - 2, -h/2 - 2])
      square([w + 4, flat_h + 2], center=false);
  }
}

// Outer shell (D-shaped) extruded along Z
module shell_outer() {
  linear_extrude(height=shell_depth, center=true)
    d_profile_keyed_2d(shell_width, shell_height, shell_corner_radius, key_flat_height);
}

// Inner cavity (offset inward) extruded along Z, slightly longer for clean subtraction
module shell_inner() {
  inner_w = shell_width - 2*shell_wall_thickness;
  inner_h = shell_height - 2*shell_wall_thickness;
  inner_r = shell_corner_radius - shell_wall_thickness;

  linear_extrude(height=shell_depth - 2*shell_wall_thickness + 2*overlap, center=true)
    d_profile_keyed_2d(inner_w, inner_h, inner_r, max(0.01, key_flat_height - shell_wall_thickness));
}

// Shell housing with cavity
module d_shell_housing() {
  difference() {
    shell_outer();
    // shift inner cavity slightly rearward so front lip remains robust
    translate([0, 0, shell_wall_thickness/2])
      shell_inner();
  }
}

// Front face plate (rectangular) with D-shaped opening + recessed pocket
module mating_face_plate() {
  // Shell front is at z = -shell_depth/2
  // Place plate so its back face overlaps into shell by "overlap"
  zc = -shell_depth/2 - face_plate_thickness/2 + overlap;

  difference() {
    translate([0, 0, zc])
      linear_extrude(height=face_plate_thickness, center=true)
        rounded_rect_2d(flange_width, flange_height, flange_corner_r);

    // Through opening (D-sub outline)
    translate([0, 0, zc])
      linear_extrude(height=face_plate_thickness + 2*overlap, center=true)
        d_profile_keyed_2d(shell_width + 2*face_opening_clear,
                           shell_height + 2*face_opening_clear,
                           shell_corner_radius + face_opening_clear,
                           key_flat_height + face_opening_clear);

    // Shallow recess on the very front side of the plate around the opening
    recess_zc = (zc - face_plate_thickness/2) + face_recess_depth/2;
    translate([0, 0, recess_zc])
      linear_extrude(height=face_recess_depth + 2*overlap, center=true)
        d_profile_keyed_2d(shell_width + 2*(face_opening_clear + face_recess_clear),
                           shell_height + 2*(face_opening_clear + face_recess_clear),
                           shell_corner_radius + (face_opening_clear + face_recess_clear),
                           key_flat_height + (face_opening_clear + face_recess_clear));
  }
}

// Mounting flange (ears) with holes (rounded corners)
module mounting_flange() {
  // Shell front is at z = -shell_depth/2
  // Place flange so its back face overlaps into shell by "overlap"
  zc = -shell_depth/2 - flange_thickness/2 + overlap;

  difference() {
    translate([0, 0, zc])
      linear_extrude(height=flange_thickness, center=true)
        rounded_rect_2d(flange_width, flange_height, flange_corner_r);

    // mount holes
    for (sx = [-1, 1]) {
      translate([sx*mount_hole_spacing/2, 0, zc])
        cylinder(r=mount_hole_diameter/2, h=flange_thickness + 2*overlap, center=true);
    }
  }
}

// Jackscrews (bosses) on front, aligned with mount holes and CONNECTED to flange
module jackscrews() {
  // Flange z center:
  flange_zc = -shell_depth/2 - flange_thickness/2 + overlap;
  // Flange front face (more negative z):
  flange_front_z = flange_zc - flange_thickness/2;

  // Put jackscrew so its BACK face overlaps into flange by "overlap"
  // back face of jackscrew = zc + jackscrew_length/2 = flange_front_z + overlap
  zc = flange_front_z + overlap - jackscrew_length/2;

  for (sx = [-1, 1]) {
    translate([sx*mount_hole_spacing/2, 0, zc])
      cylinder(r=jackscrew_diameter/2, h=jackscrew_length, center=true);
  }
}

// Pin array: 2-row staggered D-sub style, CONNECTED to face plate
module pin_array() {
  top_n = ceil(pin_count/2);
  bot_n = pin_count - top_n;

  // Face plate z center:
  face_zc = -shell_depth/2 - face_plate_thickness/2 + overlap;
  // Face plate front face (more negative z):
  face_front_z = face_zc - face_plate_thickness/2;

  // Pins should protrude out the front (negative z).
  // Ensure connection: pin BACK face overlaps into plate by "overlap"
  // back face of pin = pin_center_z + pin_length/2 = face_front_z + overlap - pin_recess_depth
  pin_center_z = face_front_z + overlap - pin_recess_depth - pin_length/2;

  for (i = [0:top_n-1]) {
    x = (-(top_n-1)/2)*pin_pitch + i*pin_pitch;
    y = row_pitch/2;
    translate([x, y, pin_center_z])
      cylinder(r=pin_diameter/2, h=pin_length, center=true);
  }

  for (i = [0:bot_n-1]) {
    x = (-(bot_n-1)/2)*pin_pitch + i*pin_pitch + row_stagger;
    y = -row_pitch/2;
    translate([x, y, pin_center_z])
      cylinder(r=pin_diameter/2, h=pin_length, center=true);
  }
}

// Rear strain relief + cable exit, CONNECTED to shell rear
module strain_relief() {
  // Rear of shell is at z = +shell_depth/2
  // Place strain relief so its FRONT face overlaps into shell rear by "overlap"
  // front face of SR = sr_zc - strain_relief_length/2 = shell_depth/2 - overlap
  sr_zc = shell_depth/2 - overlap + strain_relief_length/2;

  // SR rear face:
  sr_rear_z = sr_zc + strain_relief_length/2;

  // Place cable exit so its FRONT face overlaps into SR rear by "overlap"
  // front face of tube = tube_zc - cable_exit_length/2 = sr_rear_z - overlap
  tube_zc = sr_rear_z - overlap + cable_exit_length/2;

  difference() {
    union() {
      translate([0, 0, sr_zc])
        cylinder(r=strain_relief_diameter/2, h=strain_relief_length, center=true);

      translate([0, 0, tube_zc])
        cylinder(r=cable_exit_diameter/2 + shell_wall_thickness, h=cable_exit_length, center=true);
    }

    // Through hole for cable (span both SR + tube)
    hole_len = strain_relief_length + cable_exit_length + 4*overlap;
    hole_zc = ( (shell_depth/2 - overlap) + (tube_zc + cable_exit_length/2) )/2;
    translate([0, 0, hole_zc])
      cylinder(r=cable_exit_diameter/2, h=hole_len, center=true);
  }
}

// Front chamfer (simple bevel cut) applied to shell only
module shell_with_front_bevel() {
  difference() {
    d_shell_housing();
    translate([0, 0, -shell_depth/2 + chamfer_size/2])
      cube([shell_width + 6*shell_wall_thickness,
            shell_height + 6*shell_wall_thickness,
            chamfer_size], center=true);
  }
}

// Assembly: D-sub recognizable silhouette + pin layout + jackscrews; all connected
module d_connector() {
  union() {
    // D-shaped shell
    shell_with_front_bevel();

    // Front flange + face plate (both overlap into shell)
    mounting_flange();
    mating_face_plate();

    // Side jack-screw posts (connected to flange)
    jackscrews();

    // D-sub pin pattern (connected to face plate)
    pin_array();

    // Rear strain relief (connected to shell)
    strain_relief();
  }
}

// Final Output
d_connector();