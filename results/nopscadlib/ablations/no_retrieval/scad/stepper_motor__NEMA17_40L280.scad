// Single-shaft stepper motor (NEMA17-ish) with verifiable key dimensions:
// - face width: 42.3 mm
// - body length: 40.0 mm (front outer face to rear end)
// - shaft diameter: 8.0 mm
// - mounting hole spacing: 31.0 mm (center-to-center)
//
// One connected solid, no floating parts, all translates are formulas.

$fn = 96;

// -------------------- Parameters --------------------
face_W = 42.3;
face_H = 42.3;
face_thk = 3.0;

body_L = 40.0;                 // includes face_thk
rear_cap_thk = 2.5;

body_W = 42.3;
body_H = 42.3;
corner_r = 3.0;

shaft_d = 8.0;
shaft_L = 20.0;                // protrusion from front face only (single-shaft)

boss_d = 22.0;
boss_h = 2.0;

mount_spacing = 31.0;
mount_hole_d = 3.5;

shaft_flat_depth = 1.0;
shaft_flat_L = 12.0;

label_recess_W = 24.0;
label_recess_H = 12.0;
label_recess_depth = 0.6;

cable_exit_d = 8.0;
cable_exit_L = 12.0;
cable_exit_offset_y = 10.0;

overlap = 0.6;

// -------------------- Derived --------------------
body_core_L = body_L - face_thk;                 // length behind face plate
body_core_L_eff = body_core_L - rear_cap_thk;    // main body section length (excluding rear cap)

z_face_center = 0;
z_face_front  = z_face_center + face_thk/2;
z_face_back   = z_face_center - face_thk/2;

z_body_core_center = z_face_back - body_core_L_eff/2 + overlap/2;
z_rear_cap_center  = z_face_back - body_core_L_eff - rear_cap_thk/2 + overlap/2;

z_boss_center  = z_face_front + boss_h/2 - overlap/2;
z_shaft_center = z_face_front + shaft_L/2 - overlap/2;

// -------------------- Helpers --------------------
module rounded_square_prism(w, h, l, r, center=true) {
  linear_extrude(height=l, center=center)
    offset(r=r)
      square([w-2*r, h-2*r], center=true);
}

module mount_hole(x, y) {
  translate([x, y, z_face_center])
    cylinder(h=face_thk + 2*overlap, d=mount_hole_d, center=true);
}

module mounting_holes_pattern() {
  for (sx = [-1, 1], sy = [-1, 1])
    mount_hole(sx*mount_spacing/2, sy*mount_spacing/2);
}

module shaft_flat_cut() {
  // Flat along +X side of shaft, starting near the tip and extending back
  translate([shaft_d/2 - shaft_flat_depth, 0,
             (z_face_front + shaft_L) - shaft_flat_L/2])
    cube([shaft_d, shaft_d, shaft_flat_L + 2*overlap], center=true);
}

module label_recess_cut() {
  // Rear end plane is at: z_face_back - body_core_L
  z_rear_end = z_face_back - body_core_L;
  translate([0, 0, z_rear_end + label_recess_depth/2 + overlap/2])
    cube([label_recess_W, label_recess_H, label_recess_depth + 2*overlap], center=true);
}

module cable_exit() {
  // Cable stub exiting from rear end (negative Z), connected by overlap
  z_rear_end = z_face_back - body_core_L;
  translate([0, cable_exit_offset_y, z_rear_end - cable_exit_L/2 + overlap/2])
    cylinder(h=cable_exit_L, d=cable_exit_d, center=true);
}

// -------------------- Main solid --------------------
module main_union_raw() {
  union() {
    // Front face plate
    translate([0, 0, z_face_center])
      cube([face_W, face_H, face_thk], center=true);

    // Main body behind face
    translate([0, 0, z_body_core_center])
      rounded_square_prism(body_W, body_H, body_core_L_eff + overlap, corner_r, center=true);

    // Rear cap
    translate([0, 0, z_rear_cap_center])
      rounded_square_prism(body_W, body_H, rear_cap_thk + overlap, corner_r, center=true);

    // Front boss/pilot
    translate([0, 0, z_boss_center])
      cylinder(h=boss_h + overlap, d=boss_d, center=true);

    // Output shaft (front only)
    translate([0, 0, z_shaft_center])
      cylinder(h=shaft_L + overlap, d=shaft_d, center=true);

    // Cable exit
    cable_exit();
  }
}

module main_with_cuts() {
  difference() {
    main_union_raw();

    // Mounting holes through face plate
    mounting_holes_pattern();

    // Shaft D-flat
    shaft_flat_cut();

    // Rear label recess
    label_recess_cut();
  }
}

// Final output (single connected solid)
main_with_cuts();