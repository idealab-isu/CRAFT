// Simplified D-sub ("D connector") with recognizable D-shaped shell, flange/ears, and pin array.
// Fixes: D-shaped profile, connector face pins, mounting ears with holes, and recalculated translations
// so everything is one connected solid with slight overlaps.

$fn = 64;

// Parameters
shell_W = 30.8; //[15.4:61.6:0.1]
shell_H = 12.5; //[6.25:25:0.1]
shell_D = 12;   //[6:24:0.1]
shell_wall = 1.2; //[0.6:2.4:0.1]

insert_W = 24; //[12:48:0.1]
insert_H = 8.5; //[4.25:17:0.1]
insert_D = 6;  //[3:12:0.1]

pin_rows = 2; //[1:3:1]
pins_per_row = 5; //[2:15:1]
pin_pitch_x = 2.77; //[1.385:5.54:0.01]
pin_row_pitch_y = 2.84; //[1.42:5.68:0.01]
contact_d = 1; //[0.5:2:0.05]
contact_depth = 4; //[2:8:0.1]

ear_W = 8; //[4:16:0.1]
ear_H = 6; //[3:12:0.1]
ear_thk = 2; //[1:4:0.1]
mount_hole_d = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing = 33.3; //[16.65:66.6:0.1]

rear_stub_D = 8; //[4:16:0.1]
rear_stub_W = 18; //[9:36:0.1]
rear_stub_H = 10; //[5:20:0.1]

overlap = 1; //[0.5:2:0.1]
lip_thk = 1; //[0.5:2:0.1]
bevel_inset = 0.8; //[0.4:1.6:0.1]

key_slot_W = 2.2; //[1.1:4.4:0.1]
key_slot_H = 1.6; //[0.8:3.2:0.1]
key_slot_D = 2.5; //[1.25:5:0.1]

jackscrew_head_d = 5.5; //[2.75:11:0.1]
jackscrew_head_len = 3; //[1.5:6:0.1]

// ---------- Helpers: D-shape (flat on one side, rounded on the other) ----------
module d_profile_2d(W, H) {
  // D shape: rectangle + semicircle on the right.
  // Total width = W, height = H.
  // Flat side at x = -W/2, rounded side at x = +W/2.
  r = H/2;
  rect_w = max(0.01, W - r); // rectangle spans from -W/2 to +W/2 - r
  union() {
    translate([(-W/2 + rect_w/2), 0]) square([rect_w, H], center=true);
    translate([W/2 - r, 0]) circle(r=r);
  }
}

module d_solid(W, H, D) {
  linear_extrude(height=D, center=true) d_profile_2d(W, H);
}

// ---------- Shell + lip ----------
module d_shell_housing() {
  // Hollow D-shaped shell
  difference() {
    d_solid(shell_W, shell_H, shell_D);
    // Inner cavity shifted slightly toward rear so front face has a rim
    translate([0, 0, shell_wall])
      d_solid(shell_W - 2*shell_wall, shell_H - 2*shell_wall, shell_D - 2*shell_wall);
  }
}

module shell_lip_and_bevels() {
  // Simple front lip ring (D-shaped) with a bevel cut
  difference() {
    d_solid(shell_W + 2*lip_thk, shell_H + 2*lip_thk, lip_thk);
    d_solid(shell_W + 2*lip_thk - 2*bevel_inset,
            shell_H + 2*lip_thk - 2*bevel_inset,
            lip_thk + 2*overlap);
  }
}

// ---------- Flange / ears with holes ----------
module mounting_ears() {
  // Ears are attached to the shell sides (left/right) and centered in Y.
  // Place them at the front (mating) side so silhouette matches a D-sub flange.
  ear_z = -shell_D/2 + ear_thk/2 - overlap; // overlap into shell
  difference() {
    union() {
      translate([-mount_hole_spacing/2, 0, ear_z]) cube([ear_W, ear_H, ear_thk], center=true);
      translate([ mount_hole_spacing/2, 0, ear_z]) cube([ear_W, ear_H, ear_thk], center=true);
      // Small bridge into shell to guarantee connection even if spacing is tight
      translate([0, 0, ear_z]) cube([mount_hole_spacing - ear_W + 2*overlap, ear_H/2, ear_thk], center=true);
    }
    union() {
      // Holes through ear thickness (Z axis)
      translate([-mount_hole_spacing/2, 0, ear_z])
        cylinder(d=mount_hole_d, h=ear_thk + 2*overlap, center=true);
      translate([ mount_hole_spacing/2, 0, ear_z])
        cylinder(d=mount_hole_d, h=ear_thk + 2*overlap, center=true);
    }
  }
}

module jackscrews() {
  // Simple jack-screw heads protruding forward from the ear holes
  ear_z = -shell_D/2 + ear_thk/2 - overlap;
  head_z = ear_z - ear_thk/2 - jackscrew_head_len/2 + overlap; // forward of ears, slight overlap
  union() {
    translate([-mount_hole_spacing/2, 0, head_z])
      cylinder(d=jackscrew_head_d, h=jackscrew_head_len, center=true);
    translate([ mount_hole_spacing/2, 0, head_z])
      cylinder(d=jackscrew_head_d, h=jackscrew_head_len, center=true);
  }
}

// ---------- Insert + keying + pins ----------
module keying_features() {
  // Insulator block with a small key slot cut
  difference() {
    cube([insert_W, insert_H, insert_D], center=true);
    translate([0, insert_H/2 - key_slot_H/2, insert_D/2 - key_slot_D/2 + overlap])
      cube([key_slot_W, key_slot_H, key_slot_D + 2*overlap], center=true);
  }
}

module pins_array() {
  // Simplified pin array as cylinders protruding from the mating face
  // Place pins so they start at the front opening and extend outward.
  pin_z = -shell_D/2 - contact_depth/2 + overlap; // protrude forward from shell front
  union() {
    // Row 1 (top)
    for (i = [0:pins_per_row-1]) {
      x = (i - (pins_per_row-1)/2) * pin_pitch_x;
      translate([x, pin_row_pitch_y/2, pin_z])
        cylinder(d=contact_d, h=contact_depth, center=true);
    }
    // Row 2 (bottom) staggered by half pitch
    for (i = [0:pins_per_row-1]) {
      x = (i - (pins_per_row-1)/2) * pin_pitch_x + pin_pitch_x/2;
      translate([x, -pin_row_pitch_y/2, pin_z])
        cylinder(d=contact_d, h=contact_depth, center=true);
    }
  }
}

module rear_strain_relief_stub() {
  // Rear rectangular stub attached to back of shell
  stub_z = shell_D/2 + rear_stub_D/2 - overlap;
  translate([0, 0, stub_z]) cube([rear_stub_W, rear_stub_H, rear_stub_D], center=true);
}

// ---------- Final assembly ----------
module d_connector() {
  union() {
    // Main D-shell
    d_shell_housing();

    // Front lip (mating face rim)
    translate([0, 0, -shell_D/2 + lip_thk/2 - overlap])
      shell_lip_and_bevels();

    // Flange/ears + holes
    mounting_ears();

    // Jack-screw heads
    jackscrews();

    // Insulator insert seated just behind the front opening (inside shell)
    translate([0, 0, -shell_D/2 + shell_wall + insert_D/2 - overlap])
      keying_features();

    // Pins protruding from mating face
    pins_array();

    // Rear stub
    rear_strain_relief_stub();
  }
}

// Output
d_connector();