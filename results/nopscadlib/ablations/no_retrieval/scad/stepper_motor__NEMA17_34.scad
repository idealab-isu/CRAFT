$fn = 96;

// Target dimensions (mm)
face_W = 42.3;          // motor face width (X/Y)
body_L = 34.0;          // motor body length (Z)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing (square)

// Secondary dimensions (reasonable NEMA17-like details)
front_face_t = 3.0;
front_boss_d = 22.0;
front_boss_h = 2.0;

shaft_L = 20.0;
shaft_flat_depth = 0.5;
shaft_flat_L = 10.0;

mount_hole_d = 3.5;

rear_cap_t = 2.5;
rear_cap_margin = 0.6;

cable_conn_W = 16.0;
cable_conn_H = 10.0;
cable_conn_L = 8.0;
cable_conn_offset_y = 10.0;

corner_chamfer = 1.0;

edge_soften_enable = 0;
fillet_r = 0.8;

// Robust overlap to guarantee watertight unions/differences
overlap = 0.6;

// Derived
body_W = face_W;
body_H = face_W;

// ---------- Base solids ----------
module motor_body() {
    cube([body_W, body_H, body_L], center=true);
}

module front_face_plate() {
    translate([0, 0, body_L/2 + front_face_t/2 - overlap])
        cube([face_W, face_W, front_face_t], center=true);
}

module front_boss() {
    translate([0, 0, body_L/2 + front_face_t + front_boss_h/2 - overlap])
        cylinder(d=front_boss_d, h=front_boss_h, center=true);
}

module output_shaft() {
    translate([0, 0, body_L/2 + front_face_t + front_boss_h + shaft_L/2 - overlap])
        cylinder(d=shaft_d, h=shaft_L, center=true);
}

module rear_cap() {
    translate([0, 0, -body_L/2 - rear_cap_t/2 + overlap])
        cube([body_W - 2*rear_cap_margin, body_H - 2*rear_cap_margin, rear_cap_t], center=true);
}

module cable_connector() {
    // Ensure it intersects the rear cap/body so the whole model is one connected solid
    translate([0, cable_conn_offset_y, -body_L/2 - cable_conn_L/2 + overlap])
        cube([cable_conn_W, cable_conn_H, cable_conn_L], center=true);
}

// ---------- Cuts ----------
module shaft_flat_cut() {
    // Cut a flat on the shaft (D-shaft). Keep cut fully within shaft length.
    z0 = body_L/2 + front_face_t + front_boss_h; // shaft starts (approx) at this Z
    translate([shaft_d/2 - shaft_flat_depth/2, 0, z0 + shaft_L - shaft_flat_L/2 - overlap])
        cube([shaft_d + 2*overlap, shaft_d + 2*overlap, shaft_flat_L + 2*overlap], center=true);
}

module mount_hole(x, y) {
    // Drill through front face plate (and slightly into body/boss for clean boolean)
    zc = body_L/2 + front_face_t/2 - overlap;
    h  = front_face_t + front_boss_h + 4*overlap;
    translate([x, y, zc])
        cylinder(d=mount_hole_d, h=h, center=true);
}

module mounting_hole_pattern() {
    for (sx = [-1, 1], sy = [-1, 1])
        mount_hole(sx*mount_spacing/2, sy*mount_spacing/2);
}

module corner_chamfer_cut(x, y) {
    // Simple corner relief cut that intersects the body (not floating)
    totalZ = body_L + front_face_t + front_boss_h + shaft_L + rear_cap_t + 10;
    translate([x, y, 0])
        cube([corner_chamfer, corner_chamfer, totalZ], center=true);
}

// ---------- Assembly ----------
module motor_solid_raw() {
    union() {
        motor_body();
        front_face_plate();
        front_boss();
        output_shaft();
        rear_cap();
        cable_connector();
    }
}

module motor_booleaned() {
    difference() {
        motor_solid_raw();
        shaft_flat_cut();
        mounting_hole_pattern();

        // Corner chamfers (small, but guaranteed to intersect)
        corner_chamfer_cut( body_W/2 - corner_chamfer/2,  body_H/2 - corner_chamfer/2);
        corner_chamfer_cut(-body_W/2 + corner_chamfer/2,  body_H/2 - corner_chamfer/2);
        corner_chamfer_cut(-body_W/2 + corner_chamfer/2, -body_H/2 + corner_chamfer/2);
        corner_chamfer_cut( body_W/2 - corner_chamfer/2, -body_H/2 + corner_chamfer/2);
    }
}

module motor_final() {
    if (edge_soften_enable) {
        minkowski() {
            motor_booleaned();
            sphere(r=fillet_r);
        }
    } else {
        motor_booleaned();
    }
}

// Final output: one connected solid (with holes/flat as subtractions)
motor_final();