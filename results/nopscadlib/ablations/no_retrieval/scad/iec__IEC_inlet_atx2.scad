// IEC lugless connector (approximate IEC C14 inlet style) - single connected solid
// Fixes: recognizable IEC C14-ish mating face (keyed opening + 3 slots),
// lugless termination (no external lugs; rear cable stub only),
// all parts connected with formula-based placement + overlap.

$fn = 72;

// ---------- Parameters ----------
body_L = 50; //[25:100:1]
body_W = 28; //[14:56:1]
body_H = 22; //[11:44:1]

wall_t = 2.5; //[1.25:5:0.1]

mating_opening_W = 22; //[11:44:0.5]
mating_opening_H = 16; //[8:32:0.5]
mating_opening_depth = 12; //[6:24:0.5]

flange_W = 32; //[16:64:1]
flange_t = 3; //[1.5:6:0.1]

mount_hole_d = 3.5; //[2:7:0.1]
mount_hole_spacing = 48; //[24:96:1]

rear_entry_d = 10; //[5:20:0.5]
rear_entry_L = 12; //[6:24:1]

overlap = 1.2; //[0.5:2:0.1]
label_recess_depth = 0.8; //[0.4:1.6:0.1]

// IEC-ish face details
face_bezel_t = max(2, wall_t);
face_bezel_margin = max(2, wall_t*0.8);
nose_L = max(7, wall_t*2.4);
nose_W = min(body_W*0.94, mating_opening_W + 2*face_bezel_margin + 2);
nose_H = min(body_H*0.94, mating_opening_H + 2*face_bezel_margin + 2);

// Panel-mount "ears" (lugless: no solder lugs; panel ears/feet are common)
ear_t = max(2.2, flange_t);          // thickness along X
ear_W = max(6, wall_t*3.0);          // width along Y
ear_H = max(4, wall_t*2.0);          // height along Z
ear_y_inset = max(1.0, wall_t*0.4);  // keep ears within flange width

// Face chamfer / wedge to resemble IEC standardized profile
chamfer_L = max(3.5, wall_t*1.6);    // length of chamfer region along X
chamfer_drop = max(1.2, wall_t*0.6); // how much top/bottom taper in Z

// Internal contact slots (C14 inlet: 2 blades + ground)
pin_slot_W = 6; //[3:12:0.5]
pin_slot_H = 3; //[1.5:6:0.5]
pin_slot_depth = 10; //[5:20:0.5]
pin_slot_spacing = 10; //[6:16:0.5]

ground_slot_W = 6; //[3:12:0.5]
ground_slot_H = 4; //[2:8:0.5]

// Keying notch to make the mating opening look more IEC-like (simplified)
key_notch_W = max(6, mating_opening_W*0.35);
key_notch_H = max(3, mating_opening_H*0.28);

// Rounding
corner_r = min(2.5, min(body_W, body_H)*0.12);

// ---------- Helpers ----------
module rounded_box(L, W, H, r) {
    r2 = min(r, min(W, H)/2 - 0.01);
    hull() {
        for (sy = [-1, 1], sz = [-1, 1])
            translate([0, sy*(W/2 - r2), sz*(H/2 - r2)])
                rotate([0, 90, 0]) cylinder(r=r2, h=L, center=true);
    }
}

module wedge_chamfer(L, W, H, drop) {
    polyhedron(
        points=[
            [-L/2, -W/2, -H/2],
            [-L/2,  W/2, -H/2],
            [-L/2,  W/2,  H/2],
            [-L/2, -W/2,  H/2],

            [ L/2, -W/2, -H/2 + drop],
            [ L/2,  W/2, -H/2 + drop],
            [ L/2,  W/2,  H/2 - drop],
            [ L/2, -W/2,  H/2 - drop]
        ],
        faces=[
            [0,1,2,3],
            [4,7,6,5],
            [0,4,5,1],
            [1,5,6,2],
            [2,6,7,3],
            [3,7,4,0]
        ]
    );
}

// ---------- Base solids ----------
module main_body() {
    rounded_box(body_L, body_W, body_H, corner_r);
}

module panel_flange() {
    // Flange centered on mating face plane (x = -body_L/2)
    translate([-(body_L/2 + flange_t/2 - overlap), 0, 0])
        rounded_box(flange_t, flange_W, body_H, min(corner_r, 2));
}

module panel_ears() {
    // Two small ears on top/bottom edges of flange to resemble IEC panel-mount outline
    x = -(body_L/2 + ear_t/2 - overlap);
    y = (flange_W/2 - ear_W/2 - ear_y_inset);
    z = (body_H/2 - ear_H/2);

    for (sz = [-1, 1]) {
        translate([x,  y, sz*z]) rounded_box(ear_t, ear_W, ear_H, min(1.2, corner_r));
        translate([x, -y, sz*z]) rounded_box(ear_t, ear_W, ear_H, min(1.2, corner_r));
    }
}

module front_nose() {
    // Protruding nose on mating side to resemble IEC interface housing
    translate([-(body_L/2 + nose_L/2 - overlap), 0, 0])
        rounded_box(nose_L, nose_W, nose_H, min(corner_r, 2));
}

module rear_strain_relief() {
    // Cable entry stub on rear side (x = +body_L/2) - connected with overlap
    translate([(body_L/2 + rear_entry_L/2 - overlap), 0, 0])
        rotate([0, 90, 0])
            cylinder(r=rear_entry_d/2, h=rear_entry_L, center=true);
}

// ---------- Cuts / details ----------
module mating_opening_cut() {
    // Main rectangular opening starts at the mating face and goes inward
    translate([-(body_L/2) + mating_opening_depth/2 - overlap, 0, 0])
        cube([mating_opening_depth + 2*overlap, mating_opening_W, mating_opening_H], center=true);

    // Keying notch (simplified) to make it read as IEC-style face geometry
    // Notch at top center of opening
    notch_z = (mating_opening_H/2 - key_notch_H/2);
    translate([-(body_L/2) + (mating_opening_depth*0.55)/2 - overlap, 0, notch_z])
        cube([mating_opening_depth*0.55 + 2*overlap, key_notch_W, key_notch_H], center=true);
}

module face_bezel_relief_cut() {
    // Shallow recess around the opening on the nose to suggest a bezel
    pocket_t = min(face_bezel_t, nose_L*0.85);
    // Place pocket so it starts at the very front of the nose and goes inward
    x_front_nose = -(body_L/2 + nose_L) + overlap;
    x_center = x_front_nose + pocket_t/2;
    translate([x_center, 0, 0])
        cube([pocket_t + 2*overlap,
              mating_opening_W + 2*face_bezel_margin,
              mating_opening_H + 2*face_bezel_margin], center=true);
}

module face_chamfers_cut() {
    // Subtract top/bottom wedges near the very front to mimic IEC face profile
    x_front = -(body_L/2 + nose_L) + overlap;
    x_center = x_front + chamfer_L/2;

    translate([x_center, 0, (nose_H/2 - chamfer_drop/2)])
        wedge_chamfer(chamfer_L + 2*overlap, nose_W + 2*overlap, chamfer_drop*2 + 2*overlap, chamfer_drop);

    translate([x_center, 0, -(nose_H/2 - chamfer_drop/2)])
        wedge_chamfer(chamfer_L + 2*overlap, nose_W + 2*overlap, chamfer_drop*2 + 2*overlap, chamfer_drop);
}

module mounting_holes_cut() {
    // Two holes through flange thickness (along X)
    x0 = -(body_L/2 + flange_t/2 - overlap);
    for (sy = [-1, 1]) {
        translate([x0, sy*(mount_hole_spacing/2), 0])
            rotate([0, 90, 0])
                cylinder(r=mount_hole_d/2, h=flange_t + 4*overlap, center=true);
    }
}

module label_recess_cut() {
    // Shallow recess on top surface
    translate([0, 0, (body_H/2 - label_recess_depth/2 + overlap)])
        cube([body_L*0.35, body_W*0.6, label_recess_depth + 2*overlap], center=true);
}

module internal_slots_cut() {
    // Approximate IEC C14 inlet: two blade slots + ground slot
    // Place slots near the front, inside the opening volume.
    x = -(body_L/2) + wall_t + pin_slot_depth/2;

    // Blade slots (left/right)
    translate([x, -(pin_slot_spacing/2), 0])
        cube([pin_slot_depth + 2*overlap, pin_slot_W, pin_slot_H], center=true);
    translate([x,  (pin_slot_spacing/2), 0])
        cube([pin_slot_depth + 2*overlap, pin_slot_W, pin_slot_H], center=true);

    // Ground slot (upper center for C14 inlet look)
    z = (mating_opening_H/2) - ground_slot_H/2 - wall_t*0.25;
    translate([x, 0, z])
        cube([pin_slot_depth + 2*overlap, ground_slot_W, ground_slot_H], center=true);
}

module inner_cavity_cut() {
    // Hollow out behind the opening to avoid a solid block and better match connector shell
    cav_L = max(10, body_L - (wall_t*2 + 6));
    cav_W = max(6, body_W - 2*wall_t);
    cav_H = max(6, body_H - 2*wall_t);

    // Start cavity behind the opening depth to preserve face strength
    x_start = -(body_L/2) + mating_opening_depth + wall_t;
    // Ensure cavity stays within body length
    x_end_limit = (body_L/2) - wall_t;
    cav_L_eff = min(cav_L, max(6, x_end_limit - x_start));
    x_center = x_start + cav_L_eff/2;

    translate([x_center, 0, 0])
        rounded_box(cav_L_eff + 2*overlap, cav_W, cav_H, max(0.8, corner_r*0.6));
}

// ---------- Final model ----------
module iec_lugless_connector() {
    difference() {
        union() {
            // One connected solid: body + flange + ears + nose + rear cable stub
            main_body();
            panel_flange();
            panel_ears();
            front_nose();
            rear_strain_relief();
        }

        // IEC face opening + details (recognizable C14-ish)
        mating_opening_cut();
        face_bezel_relief_cut();
        face_chamfers_cut();

        // Internal features
        internal_slots_cut();
        inner_cavity_cut();

        // Mounting + cosmetic
        mounting_holes_cut();
        label_recess_cut();
    }
}

iec_lugless_connector();