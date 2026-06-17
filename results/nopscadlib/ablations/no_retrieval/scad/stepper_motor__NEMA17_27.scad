// Stepper motor (NEMA-like) - fixed for visibility, connectivity, and key dimensions
// Required: 42.3mm face width, 26.5mm body length, 5.0mm shaft diameter, 31.0mm mounting hole spacing

$fn = 96;

// -------------------- Parameters --------------------
face_W = 42.3;
body_W = 42.3;
body_H = 42.3;
body_L = 26.5;

face_thk = 3.0;

shaft_d = 5.0;
shaft_L = 20.0;

mount_spacing = 31.0;     // center-to-center spacing (square pattern)
mount_hole_d = 3.2;

boss_d = 22.0;
boss_h = 2.0;

rear_cap_thk = 2.5;

shaft_flat_depth = 0.5;
shaft_flat_L = 10.0;

label_recess_W = 18.0;
label_recess_H = 10.0;
label_recess_depth = 0.6;

cable_exit_W = 10.0;
cable_exit_H = 6.0;
cable_exit_L = 8.0;
cable_exit_hole_d = 4.0;

overlap = 0.8;            // overlap to guarantee watertight unions/differences

// -------------------- Z placement helpers (all formula-based) --------------------
function z_body_front() =  body_L/2;
function z_body_back()  = -body_L/2;

function z_face_center() = z_body_front() + face_thk/2 - overlap;
function z_face_front()  = z_body_front() + face_thk - overlap;

function z_boss_center()  = z_face_front() + boss_h/2 - overlap;
function z_boss_front()   = z_face_front() + boss_h - overlap;

function z_shaft_center() = z_boss_front() + shaft_L/2 - overlap;

function z_rear_cap_center()   = z_body_back() - rear_cap_thk/2 + overlap;
function z_cable_exit_center() = z_body_back() - cable_exit_L/2 + overlap;

// -------------------- Base solids --------------------
module motor_body() {
    cube([body_W, body_H, body_L], center=true);
}

module front_face_plate() {
    translate([0, 0, z_face_center()])
        cube([face_W, face_W, face_thk], center=true);
}

module front_face_boss() {
    translate([0, 0, z_boss_center()])
        cylinder(d=boss_d, h=boss_h, center=true);
}

module output_shaft() {
    translate([0, 0, z_shaft_center()])
        cylinder(d=shaft_d, h=shaft_L, center=true);
}

module rear_cap() {
    translate([0, 0, z_rear_cap_center()])
        cube([body_W, body_H, rear_cap_thk], center=true);
}

module cable_exit_block() {
    // Attached to rear face, centered on motor
    translate([0, 0, z_cable_exit_center()])
        cube([cable_exit_W, cable_exit_H, cable_exit_L], center=true);
}

// -------------------- Subtractive features --------------------
module mount_hole_at(x, y) {
    // Drill through face plate and slightly into body for clear visibility
    translate([x, y, z_face_center()])
        cylinder(d=mount_hole_d, h=face_thk + 2.0 + 4*overlap, center=true);
}

module mounting_hole_pattern() {
    for (sx = [-1, 1], sy = [-1, 1])
        mount_hole_at(sx*mount_spacing/2, sy*mount_spacing/2);
}

module shaft_flat_cut() {
    // D-flat: remove shaft_flat_depth from radius on +X side over last shaft_flat_L near tip
    // Flat plane at x = (shaft_d/2 - shaft_flat_depth)
    x_plane = shaft_d/2 - shaft_flat_depth;

    // Put a big cutter cube whose -X face sits on x_plane, so everything with x > x_plane is removed
    cutter_x = (shaft_d + 6); // generous
    x_center = x_plane + cutter_x/2;

    z_tip = z_shaft_center() + shaft_L/2;
    z_flat_center = z_tip - shaft_flat_L/2;

    translate([x_center, 0, z_flat_center])
        cube([cutter_x, shaft_d + 6, shaft_flat_L + 4*overlap], center=true);
}

module label_recess_cut() {
    // Recess on the front face (shallow), cut into the face plate
    // Centered slightly behind the very front surface so it actually removes material
    z_center = z_body_front() + face_thk - label_recess_depth/2 - overlap;
    translate([0, 0, z_center])
        cube([label_recess_W, label_recess_H, label_recess_depth + 4*overlap], center=true);
}

module cable_exit_hole_cut() {
    // Hole through the cable exit block along Y axis
    translate([0, 0, z_cable_exit_center()])
        rotate([90, 0, 0])
            cylinder(d=cable_exit_hole_d, h=cable_exit_H + 4*overlap, center=true);
}

// -------------------- Final model --------------------
module final_model() {
    difference() {
        // ONE connected solid (all parts overlap slightly)
        union() {
            motor_body();
            front_face_plate();
            front_face_boss();
            output_shaft();
            rear_cap();
            cable_exit_block();
        }

        // Visible/verifiable features
        mounting_hole_pattern();
        label_recess_cut();
        shaft_flat_cut();
        cable_exit_hole_cut();
    }
}

// Avoid solid-black silhouette in many renderers: use a lighter color
color([0.65, 0.65, 0.65]) final_model();