// Simplified D-sub ("D connector") with recognizable D-shaped shell,
// recessed mating face + pin holes, and side mounting ears with screw holes.
// All parts are connected with small overlaps for watertight union.

// ---------- Parameters ----------
$fn = 64;

shell_W = 30.8;          // overall D-shell width (X)
shell_H = 12.5;          // overall D-shell height (Y)
shell_D = 10;            // D-shell depth (Z)
face_t  = 2;             // front face thickness (Z)

rear_W = 26;
rear_H = 10;
rear_D = 18;

flange_W = 39;           // overall flange width (X)
flange_H = 15;           // overall flange height (Y)
flange_t = 2.5;          // flange thickness (Z)

mount_hole_d = 3.2;
mount_hole_spacing = 25;

overlap = 1.2;           // 1–2mm overlap for solid connections
shell_wall = 1.2;

pin_pitch_x = 2.77;
pin_pitch_y = 2.84;

jackscrew_d = 5;
jackscrew_len = 8;

strain_relief_d = 12;
strain_relief_len = 14;

fillet_r = 0.8;

// Recess + pin field
recess_depth = 1.2;      // how deep the mating face recess is
recess_margin = 1.6;     // inset from shell edge
pin_hole_d = 1.2;        // visible holes

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2-r2,  h/2-r2]) circle(r=r2);
    translate([-w/2+r2,  h/2-r2]) circle(r=r2);
    translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    translate([-w/2+r2, -h/2+r2]) circle(r=r2);
  }
}

// D-profile: flat on one side, rounded on the other.
// Implemented as intersection of a rectangle and a circle.
module d_profile_2d(w, h) {
  r = h/2;
  intersection() {
    circle(r=r);
    translate([w/2 - r, 0]) square([w, h], center=true);
  }
}

module d_shell_solid(w, h, d) {
  linear_extrude(height=d, center=true)
    d_profile_2d(w, h);
}

module d_shell_hollow(w, h, d, wall) {
  // Fix: inner cavity must be a solid subtraction with correct signature.
  // Also keep it slightly longer in Z to guarantee a clean cut.
  difference() {
    d_shell_solid(w, h, d);
    d_shell_solid(w-2*wall, h-2*wall, d + 2*overlap);
  }
}

// ---------- Main Features ----------
module flange_with_ears() {
  // Place flange so its FRONT face is slightly behind the shell front,
  // ensuring overlap/connection with the shell and face plate.
  // Shell front plane: z = -shell_D/2
  // Flange front plane: z = -shell_D/2 + overlap
  zc = (-shell_D/2 + overlap) + flange_t/2;

  difference() {
    translate([0, 0, zc])
      linear_extrude(height=flange_t, center=true)
        rounded_rect_2d(flange_W, flange_H, r=2);

    for (sx = [-1, 1]) {
      translate([sx*mount_hole_spacing/2, 0, zc])
        cylinder(d=mount_hole_d, h=flange_t + 2*overlap, center=true);
    }
  }
}

module recessed_mating_face() {
  // Face plate sits at the very front, overlapping into shell by 'overlap'.
  // Shell front plane: z = -shell_D/2
  // Face plate spans: [-shell_D/2 - overlap, -shell_D/2 - overlap + face_t]
  zc_face = (-shell_D/2 - overlap) + face_t/2;

  // Recess pocket starts at the shell front and goes inward.
  // Pocket spans: [-shell_D/2, -shell_D/2 + recess_depth]
  zc_pocket = (-shell_D/2) + recess_depth/2;

  difference() {
    translate([0, 0, zc_face])
      linear_extrude(height=face_t, center=true)
        d_profile_2d(shell_W, shell_H);

    translate([0, 0, zc_pocket])
      linear_extrude(height=recess_depth + 2*overlap, center=true)
        d_profile_2d(shell_W - 2*recess_margin, shell_H - 2*recess_margin);

    // Pin holes (simplified DE-9: 5 + 4)
    // Drill through face and slightly into recess.
    hole_h = face_t + recess_depth + 2*overlap;
    for (i = [-2:2]) {
      translate([i*pin_pitch_x,  pin_pitch_y/2, zc_face])
        cylinder(d=pin_hole_d, h=hole_h, center=true);
    }
    for (i = [-1.5:1:1.5]) {
      translate([i*pin_pitch_x, -pin_pitch_y/2, zc_face])
        cylinder(d=pin_hole_d, h=hole_h, center=true);
    }
  }
}

module jackscrews() {
  // Start just behind the flange and extend rearward (+Z), overlapping flange.
  // Flange back plane: z = (-shell_D/2 + overlap) + flange_t
  z_start = (-shell_D/2 + overlap) + flange_t - overlap; // overlap into flange
  zc = z_start + jackscrew_len/2;

  for (sx = [-1, 1]) {
    translate([sx*mount_hole_spacing/2, 0, zc])
      cylinder(d=jackscrew_d, h=jackscrew_len, center=true);
  }
}

module rear_housing() {
  // Attach rear housing to shell back with overlap.
  // Shell back plane: z = +shell_D/2
  // Rear housing front plane: z = +shell_D/2 - overlap
  zc = (shell_D/2 - overlap) + rear_D/2;
  translate([0, 0, zc])
    cube([rear_W, rear_H, rear_D], center=true);
}

module strain_relief() {
  // Attach to rear housing back with overlap.
  // Rear housing back plane: z = (shell_D/2 - overlap) + rear_D
  z_back_rear = (shell_D/2 - overlap) + rear_D;
  zc = (z_back_rear - overlap) + strain_relief_len/2;

  translate([0, 0, zc])
    cylinder(d=strain_relief_d, h=strain_relief_len, center=true);
}

// ---------- Assembly ----------
module connector_core_union() {
  union() {
    // D-shaped shell (hollow)
    d_shell_hollow(shell_W, shell_H, shell_D, shell_wall);

    // Flange with mounting ears/holes
    flange_with_ears();

    // Recessed mating face with pin holes
    recessed_mating_face();

    // Rear housing + strain relief
    rear_housing();
    strain_relief();

    // Jackscrews
    jackscrews();
  }
}

module filleted() {
  minkowski() {
    connector_core_union();
    sphere(r=fillet_r);
  }
}

// ---------- Final Output ----------
filleted();