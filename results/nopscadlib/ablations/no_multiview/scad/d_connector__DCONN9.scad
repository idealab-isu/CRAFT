// Simplified D-sub ("D connector") model
// Fixes: make silhouette clearly D-shaped, add recessed mating face,
// keep all parts connected with computed translates + small overlaps.

$fn = 64;

// ---------- Parameters ----------
shell_W = 30;              // D width
shell_H = 12;              // D height
shell_D = 10;              // shell depth (front-to-back)

flange_W = 40;             // flange overall width
flange_H = 16;             // flange overall height
flange_t = 2.5;            // flange thickness

mount_hole_d = 3.2;
mount_hole_spacing = 33;   // center-to-center of mounting holes

screw_jack_d = 6;
screw_jack_len = 6;

contact_count = 9;
contact_pitch = 2.77;
pin_d = 1;
pin_len = 3;

shell_corner_r = 1.0;      // mild rounding
overlap = 1.2;             // overlap to ensure watertight unions

rear_stub_d = 18;
rear_stub_L = 12;

shell_lip_t = 1.2;
shell_lip_scale = 0.92;

// Recessed mating face (key D-sub cue)
recess_depth = 2.0;        // how deep the front face is recessed
recess_scale = 0.86;       // smaller D-profile for recess opening

// ---------- Helpers ----------
module d_profile_2d(w, h) {
  // D profile: flat on left, rounded on right
  r = h/2;
  rect_w = max(0.01, w - r);
  union() {
    translate([-(w/2) + rect_w/2, 0])
      square([rect_w, h], center=true);
    translate([w/2 - r, 0])
      circle(r=r);
  }
}

module d_shell_solid(w, h, d) {
  linear_extrude(height=d, center=true)
    d_profile_2d(w, h);
}

module rounded_solid(obj_r=1.0) {
  minkowski() {
    children();
    sphere(r=obj_r);
  }
}

// ---------- Major Parts ----------
module shell_body() {
  // Rounded D-shell (main recognizable silhouette)
  rounded_solid(shell_corner_r)
    d_shell_solid(shell_W, shell_H, shell_D);
}

module front_lip() {
  // Thin lip at the very front, slightly smaller than shell profile
  z_front = -shell_D/2;
  translate([0,0, z_front + shell_lip_t/2 - overlap])
    linear_extrude(height=shell_lip_t, center=true)
      scale([shell_lip_scale, shell_lip_scale])
        d_profile_2d(shell_W, shell_H);
}

module mounting_flange() {
  // Flange sits just behind the front face and intersects shell
  z_front = -shell_D/2;
  translate([0,0, z_front + flange_t/2 + overlap])
    cube([flange_W, flange_H, flange_t], center=true);
}

module mounting_holes_cut() {
  // Through flange thickness
  z_front = -shell_D/2;
  zc = z_front + flange_t/2 + overlap;
  for (sx=[-1,1]) {
    translate([sx*mount_hole_spacing/2, 0, zc])
      cylinder(d=mount_hole_d, h=flange_t + 2*overlap, center=true);
  }
}

module jack_screws() {
  // Cylinders behind flange, aligned with mounting holes, overlapping flange
  z_front = -shell_D/2;
  z_flange_back = (z_front + flange_t/2 + overlap) + flange_t/2; // back face of flange
  translate([0,0,0]) {
    for (sx=[-1,1]) {
      translate([sx*mount_hole_spacing/2, 0, z_flange_back + screw_jack_len/2 - overlap])
        cylinder(d=screw_jack_d, h=screw_jack_len, center=true);
    }
  }
}

module rear_stub() {
  // Cable/strain relief stub at the back of shell, overlapping shell
  z_back = shell_D/2;
  translate([0,0, z_back + rear_stub_L/2 - overlap])
    cylinder(d=rear_stub_d, h=rear_stub_L, center=true);
}

module pins() {
  // Pins start inside the recessed cavity and extend slightly forward
  z_front = -shell_D/2;
  // Place pin center so the back of pins overlaps into the shell by overlap
  z_pin_center = z_front + recess_depth - pin_len/2 + overlap;

  x0 = -((contact_count-1)*contact_pitch)/2;
  for (i=[0:contact_count-1]) {
    translate([x0 + i*contact_pitch, 0, z_pin_center])
      cylinder(d=pin_d, h=pin_len, center=true);
  }
}

module mating_recess_cut() {
  // Recessed mating face cavity (simplified D-sub cue)
  z_front = -shell_D/2;
  // Cut starts at the very front and goes inward
  translate([0,0, z_front + recess_depth/2 + overlap])
    linear_extrude(height=recess_depth + 2*overlap, center=true)
      scale([recess_scale, recess_scale])
        d_profile_2d(shell_W, shell_H);
}

// ---------- Assembly ----------
module d_connector() {
  difference() {
    union() {
      shell_body();
      front_lip();
      mounting_flange();
      jack_screws();
      rear_stub();
      pins();
    }
    mounting_holes_cut();
    mating_recess_cut();
  }
}

d_connector();