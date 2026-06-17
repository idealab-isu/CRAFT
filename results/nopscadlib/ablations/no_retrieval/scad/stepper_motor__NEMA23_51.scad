$fn = 128;

// -------------------- Parameters (mm) --------------------
face_W = 56.4;                 // front face width/height
body_W = 56.4;                 // body width
body_H = 56.4;                 // body height
body_L = 51.2;                 // body length (front-to-back)

shaft_d = 6.35;                // shaft diameter
shaft_L = 20;

mount_spacing = 47.1;          // hole center-to-center spacing (square pattern)
mount_hole_d = 3.5;

face_thk = 3;
boss_d = 22;
boss_h = 2;

flat_depth = 0.5;              // D-flat depth (radial)
flat_L = 12;

rear_cap_thk = 2.5;
rear_cap_margin = 1.0;

connector_W = 18;
connector_H = 10;
connector_L = 8;
connector_offset_Y = 0;

counterbore_d = 6.5;
counterbore_depth = 2.0;

overlap = 0.6;
chamfer_size = 1.0;

// Visual/verification helpers (do not change geometry)
show_cutaway = true;           // enables a thin cutaway so holes/shaft are visible in ortho views
cutaway_thk = 0.8;             // thickness of removed slice
cutaway_offset = face_W/2 - cutaway_thk/2;  // slice near +X edge (keeps most silhouette intact)

// -------------------- Helpers --------------------
module mount_hole(h) {
    cylinder(d=mount_hole_d, h=h, center=true);
}

module counterbore(h) {
    cylinder(d=counterbore_d, h=h, center=true);
}

module mounting_hole_pattern(h) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*mount_spacing/2, sy*mount_spacing/2, 0])
            mount_hole(h);
}

module mounting_counterbore_pattern(h) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*mount_spacing/2, sy*mount_spacing/2, 0])
            counterbore(h);
}

// -------------------- Parts --------------------
module motor_body() {
    cube([body_W, body_H, body_L], center=true);
}

module front_face_with_holes() {
    difference() {
        cube([face_W, face_W, face_thk], center=true);

        // Through holes
        mounting_hole_pattern(face_thk + 2*overlap);

        // Counterbores from the FRONT side only (+Z in local face coords)
        translate([0, 0, +face_thk/2 - counterbore_depth/2])
            mounting_counterbore_pattern(counterbore_depth + 2*overlap);
    }
}

module front_boss() {
    cylinder(d=boss_d, h=boss_h, center=true);
}

module shaft_with_flat() {
    difference() {
        cylinder(d=shaft_d, h=shaft_L, center=true);

        // D-flat: remove material for x > (shaft_r - flat_depth)
        shaft_r = shaft_d/2;
        x_plane = shaft_r - flat_depth;

        // Big cutter cube whose -X face sits at x_plane
        translate([x_plane + (shaft_d*2)/2, 0, shaft_L/2 - flat_L/2])
            cube([shaft_d*2, shaft_d*2, flat_L + 2*overlap], center=true);
    }
}

module rear_cap() {
    cube([body_W + 2*rear_cap_margin, body_H + 2*rear_cap_margin, rear_cap_thk], center=true);
}

module cable_connector() {
    cube([connector_W, connector_H, connector_L], center=true);
}

// Chamfer cutter: long prism used to nibble corners
module chamfer_cut(total_z) {
    cube([chamfer_size, chamfer_size, total_z], center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module motor_geometry() {
    total_z_for_chamfer = body_L + face_thk + rear_cap_thk + boss_h + shaft_L + 20;

    difference() {
        union() {
            // Main body
            motor_body();

            // Front face (attached to front of body)
            translate([0, 0, body_L/2 + face_thk/2 - overlap])
                front_face_with_holes();

            // Front boss (attached to front face)
            translate([0, 0, body_L/2 + face_thk - overlap + boss_h/2])
                front_boss();

            // Shaft (attached to boss)
            translate([0, 0, body_L/2 + face_thk - overlap + boss_h - overlap + shaft_L/2])
                shaft_with_flat();

            // Rear cap (attached to back of body)
            translate([0, 0, -body_L/2 - rear_cap_thk/2 + overlap])
                rear_cap();

            // Connector (attached to rear cap; overlap into cap)
            translate([0, connector_offset_Y,
                       (-body_L/2 - rear_cap_thk + overlap) - connector_L/2 + overlap])
                cable_connector();
        }

        // Corner chamfers on the main body only (do not cut shaft/connector)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(body_W/2 - chamfer_size/2),
                       sy*(body_H/2 - chamfer_size/2),
                       0])
                chamfer_cut(total_z_for_chamfer);
    }
}

module motor_solid() {
    // Keep as ONE connected solid, but add a thin cutaway slice so ortho views
    // show mounting holes and shaft diameter clearly.
    difference() {
        motor_geometry();

        if (show_cutaway)
            translate([cutaway_offset, 0, 0])
                cube([cutaway_thk, face_W*3, (body_L + face_thk + rear_cap_thk + boss_h + shaft_L)*3],
                     center=true);
    }
}

// -------------------- Output --------------------
motor_solid();