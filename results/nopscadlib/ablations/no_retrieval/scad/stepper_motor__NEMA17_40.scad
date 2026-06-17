// Stepper motor (NEMA-style) parametric model
// Target key dimensions:
// - face_W = 42.3 mm (square face width)
// - body_L = 40.0 mm (body length, excluding front face + rear cap)
// - shaft_d = 5.0 mm
// - mount_spacing = 31.0 mm (hole center-to-center)

// ---------------- Parameters ----------------
face_W = 42.3; //[21.15:84.6:0.1]
body_L = 40.0; //[20.0:80.0:0.1]

body_corner_r = 3.0; //[0.0:6.0:0.1]   // visual only (2D offset rounding)
front_face_t = 3.0; //[1.5:6.0:0.1]
rear_cap_t = 2.0; //[1.0:6.0:0.1]

shaft_d = 5.0; //[2.5:10.0:0.1]
shaft_L = 20.0; //[10.0:40.0:0.1]

mount_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_d = 3.5; //[2.0:6.0:0.1]

boss_d = 22.0; //[11.0:44.0:0.1]
boss_h = 2.0; //[1.0:6.0:0.1]

cable_conn_W = 14.0; //[7.0:28.0:0.1]
cable_conn_H = 10.0; //[5.0:20.0:0.1]
cable_conn_L = 8.0;  //[4.0:16.0:0.1]
cable_conn_offset_x = 0.0; //[-10.0:10.0:0.1]
cable_conn_offset_z = 0.0; //[-10.0:10.0:0.1]

counterbore_d = 6.5; //[4.0:10.0:0.1]
counterbore_depth = 1.5; //[0.5:4.0:0.1]

overlap = 1.0; //[0.5:2.0:0.1]  // used to ensure watertight unions/differences
chamfer_size = 1.0; //[0.0:3.0:0.1]

shaft_flat_depth = 0.5; //[0.0:1.5:0.1]
shaft_flat_width = 2.0; //[0.5:4.0:0.1]

// ---------------- Derived ----------------
total_L = front_face_t + body_L + rear_cap_t; // overall length excluding shaft/boss
y_front = 0;                                  // front face outer plane at y=0
y_back  = -total_L;                           // rear cap outer plane at y=-total_L

$fn = 96;

// ---------------- Helpers ----------------
module rounded_square_prism(w, h, r, center=true) {
  // Rounded in XZ, extruded along Y
  // If r==0, becomes a plain cube.
  if (r <= 0) {
    cube([w, h, w], center=center);
  } else {
    linear_extrude(height=h, center=center)
      offset(r=r)
        square([w-2*r, w-2*r], center=true);
  }
}

module y_cyl(r, h, center=true) {
  rotate([90,0,0]) cylinder(r=r, h=h, center=center);
}

// ---------------- Parts (all connected by formulas) ----------------
module motor_body() {
  // Body spans y = [-front_face_t - body_L, -front_face_t]
  translate([0, -(front_face_t + body_L/2), 0])
    rounded_square_prism(face_W, body_L + overlap, body_corner_r, center=true);
}

module front_face() {
  // Front face spans y = [-front_face_t, 0]
  translate([0, -front_face_t/2, 0])
    rounded_square_prism(face_W, front_face_t + overlap, body_corner_r, center=true);
}

module rear_cap() {
  // Rear cap spans y = [-total_L, -total_L + rear_cap_t]
  translate([0, -(front_face_t + body_L + rear_cap_t/2), 0])
    rounded_square_prism(face_W, rear_cap_t + overlap, body_corner_r, center=true);
}

module front_boss_register() {
  // Boss protrudes out of front face: y = [0, boss_h]
  translate([0, boss_h/2 - overlap/2, 0])
    y_cyl(boss_d/2, boss_h + overlap, center=true);
}

module output_shaft() {
  // Shaft protrudes out of front face: y = [0, shaft_L]
  translate([0, shaft_L/2 - overlap/2, 0])
    y_cyl(shaft_d/2, shaft_L + overlap, center=true);
}

module cable_connector() {
  // Connector attached to rear cap, protruding further back:
  // rear cap outer plane at y = -total_L, connector extends to y = -total_L - cable_conn_L
  translate([cable_conn_offset_x,
             -(total_L + cable_conn_L/2 - overlap/2),
             cable_conn_offset_z])
    cube([cable_conn_W, cable_conn_L + overlap, cable_conn_H], center=true);
}

// ---------------- Mount holes (clear through-holes) ----------------
module mount_hole_at(x, z) {
  // Through front face only (typical mounting holes in flange)
  // Front face spans y=[-front_face_t,0], so center at -front_face_t/2
  translate([x, -front_face_t/2, z])
    y_cyl(mount_hole_d/2, front_face_t + overlap*4, center=true);
}

module mount_counterbore_at(x, z) {
  // Counterbore from the front (y near 0) into the front face
  // Place so it starts at y=0 and goes inward by counterbore_depth
  translate([x, -(counterbore_depth/2), z])
    y_cyl(counterbore_d/2, counterbore_depth + overlap*4, center=true);
}

module mount_holes_and_counterbores() {
  for (sx = [-1, 1], sz = [-1, 1]) {
    mount_hole_at(sx*mount_spacing/2, sz*mount_spacing/2);
    mount_counterbore_at(sx*mount_spacing/2, sz*mount_spacing/2);
  }
}

// ---------------- Shaft flat (subtractive, keeps one connected solid) ----------------
module shaft_flat_cut() {
  // Cut a flat on the shaft along +X side.
  // Only cut within the shaft length region to avoid affecting body.
  // Shaft spans y=[0, shaft_L]; center at shaft_L/2.
  translate([shaft_d/2 - shaft_flat_depth/2, shaft_L/2, 0])
    cube([shaft_flat_depth + overlap*2, shaft_L + overlap*2, shaft_flat_width], center=true);
}

// ---------------- Corner chamfers (subtractive) ----------------
module corner_chamfer_cuts() {
  if (chamfer_size > 0) {
    // Cut small cubes at the four XZ corners across the whole motor length (including connector overlap)
    cut_len = total_L + cable_conn_L + shaft_L + boss_h + overlap*8;
    y_center = -(total_L/2); // centered roughly through motor; long enough anyway
    for (sx = [-1, 1], sz = [-1, 1]) {
      translate([sx*(face_W/2 - chamfer_size/2),
                 y_center,
                 sz*(face_W/2 - chamfer_size/2)])
        cube([chamfer_size, cut_len, chamfer_size], center=true);
    }
  }
}

// ---------------- Assembly ----------------
module motor_solid() {
  union() {
    motor_body();
    front_face();
    rear_cap();
    front_boss_register();
    output_shaft();
    cable_connector();
  }
}

module final_motor_model() {
  difference() {
    motor_solid();
    mount_holes_and_counterbores(); // clear through-holes + counterbores
    shaft_flat_cut();               // flat is a cut, not an added floating part
    corner_chamfer_cuts();
  }
}

// ---------------- Output ----------------
final_motor_model();