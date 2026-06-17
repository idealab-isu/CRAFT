// Parameters
faceplate_w = 86; //[60:172]
faceplate_h = 86; //[60:172]
faceplate_t = 8; //[4:16]
minkowski_sphere_r = 1.5; //[0.5:4]
overlap = 1; //[0.5:2]
pin_cut_depth = 12; //[6:24]
pin_live_neutral_pitch_x = 22.2; //[18:28]
pin_row_y = -11.1; //[-16:-6]
pin_earth_y = 11.1; //[6:16]
pin_ln_w = 7; //[5:10]
pin_ln_h = 4.5; //[3:7]
pin_earth_w = 4.5; //[3:7]
pin_earth_h = 8.5; //[6:12]
rear_cavity_w = 74; //[50:140]
rear_cavity_h = 74; //[50:140]
rear_cavity_depth = 6; //[2:14]
screw_pitch_y = 60.3; //[45:90]
screw_hole_d = 3.5; //[2.5:5]
counterbore_d = 7.5; //[5.5:12]
counterbore_depth = 3; //[1:6]
earth_ref_boss_d = 8; //[4:16]
earth_ref_boss_h = 1.5; //[0.5:4]
earth_ref_inset = 8; //[4:16]

// Mains Socket - complete geometry
module mains_socket() {
  color("White") {
    // Faceplate with rounded edges
    minkowski() {
      cube([faceplate_w - 2*minkowski_sphere_r, faceplate_h - 2*minkowski_sphere_r, faceplate_t - 2*minkowski_sphere_r], center=true);
      sphere(r=minkowski_sphere_r, center=true);
    }
  }
}

// Mains Socket Holes - complete geometry
module mains_socket_holes() {
  color("Black") {
    // Pin apertures
    union() {
      translate([-pin_live_neutral_pitch_x/2, pin_row_y, faceplate_t/2 - pin_cut_depth/2 + overlap])
        cube([pin_ln_w, pin_ln_h, pin_cut_depth], center=true);
      translate([pin_live_neutral_pitch_x/2, pin_row_y, faceplate_t/2 - pin_cut_depth/2 + overlap])
        cube([pin_ln_w, pin_ln_h, pin_cut_depth], center=true);
      translate([0, pin_earth_y, faceplate_t/2 - pin_cut_depth/2 + overlap])
        cube([pin_earth_w, pin_earth_h, pin_cut_depth], center=true);
    }
    // Rear hollow cavity
    translate([0, 0, -faceplate_t/2 + rear_cavity_depth/2 - overlap/2])
      cube([rear_cavity_w, rear_cavity_h, rear_cavity_depth + overlap], center=true);
    // Mounting screw holes
    translate([0, screw_pitch_y/2, 0])
      cylinder(r=screw_hole_d/2, h=faceplate_t + 2*overlap, center=true);
    translate([0, -screw_pitch_y/2, 0])
      cylinder(r=screw_hole_d/2, h=faceplate_t + 2*overlap, center=true);
    // Screw counterbores
    translate([0, screw_pitch_y/2, faceplate_t/2 - counterbore_depth/2 + overlap/2])
      cylinder(r=counterbore_d/2, h=counterbore_depth + overlap, center=true);
    translate([0, -screw_pitch_y/2, faceplate_t/2 - counterbore_depth/2 + overlap/2])
      cylinder(r=counterbore_d/2, h=counterbore_depth + overlap, center=true);
  }
}

// Mains Socket Earth Position - complete geometry
module mains_socket_earth_position() {
  color("Green") {
    // Earth terminal position reference boss
    translate([-faceplate_w/2 + earth_ref_inset, -faceplate_h/2 + earth_ref_inset, faceplate_t/2 + earth_ref_boss_h/2 - overlap])
      cylinder(r=earth_ref_boss_d/2, h=earth_ref_boss_h, center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    mains_socket();
    mains_socket_holes();
  }
  if (include_earth_terminal_feature) {
    mains_socket_earth_position();
  }
}

assembly();