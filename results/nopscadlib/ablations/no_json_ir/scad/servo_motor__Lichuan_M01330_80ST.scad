// Lichuan -80M01330B style servo motor (approximate form factor)
// Connectivity-fixed: side connector block is now physically attached with 1–2mm overlap.

$fn = 96;

// -------------------- Parameters --------------------
motor_len = 80;                 // main body length (Z)
body_d = 80;                    // 80mm frame class (approx OD)
flat_frac = 0.18;               // amount of "squaring" on sides (0..0.35)

front_flange_thk = 6;
front_flange_w = 90;            // square flange width
front_flange_h = 90;            // square flange height
front_flange_corner_r = 4;

pilot_d = 55;
pilot_depth = 2.5;

shaft_d = 19;
shaft_len = 35;

rear_boss_d = 28;
rear_boss_len = 10;

connector_w = 22;
connector_h = 14;
connector_len = 18;
connector_offset_y = 0;         // centered on Y
connector_offset_z = 0;         // centered on Z

// Mounting holes (subtracted from flange)
mount_hole_d = 6.5;
mount_hole_pitch_x = 70;        // center-to-center
mount_hole_pitch_y = 70;
mount_hole_depth = front_flange_thk + 0.6;

// Overlap to guarantee watertight unions (1–2mm per requirements)
ov = 1.5;

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

// "Squared" cylinder by intersecting a cylinder with a rounded rectangle prism
module squared_cylinder(d, h, flat_fraction=0.18, corner_r=6) {
    rect_w = d * (1 - flat_fraction);
    rect_h = d * (1 - flat_fraction);
    intersection() {
        cylinder(d=d, h=h, center=true);
        linear_extrude(height=h + 2*ov, center=true)
            rounded_rect_2d(rect_w, rect_h, corner_r);
    }
}

// -------------------- Parts --------------------
module motor_body() {
    squared_cylinder(body_d, motor_len, flat_frac, corner_r=8);
}

module front_flange() {
    // Centered at front end, overlapping into body by ov
    zc = motor_len/2 - front_flange_thk/2 + ov/2;
    translate([0,0,zc])
        linear_extrude(height=front_flange_thk + ov, center=true)
            rounded_rect_2d(front_flange_w, front_flange_h, front_flange_corner_r);
}

module front_pilot() {
    // Pilot register sits on the flange front face, overlapping into flange by ov
    zc = motor_len/2 + pilot_depth/2;
    translate([0,0,zc])
        cylinder(d=pilot_d, h=pilot_depth + ov, center=true);
}

module output_shaft() {
    // Shaft starts at pilot front face and protrudes forward, overlapping into pilot by ov
    zc = motor_len/2 + pilot_depth + shaft_len/2;
    translate([0,0,zc])
        cylinder(d=shaft_d, h=shaft_len + ov, center=true);
}

module rear_boss() {
    // Rear boss attached to back face, overlapping into body by ov
    zc = -motor_len/2 - rear_boss_len/2 + ov/2;
    translate([0,0,zc])
        cylinder(d=rear_boss_d, h=rear_boss_len + ov, center=true);
}

module connector_block() {
    // Side connector block attached to body (+X) with guaranteed intersection.
    // Use the *inscribed* rectangle half-width of the squared body (not body_d/2),
    // otherwise it can float outside the flattened sides.
    rect_w = body_d * (1 - flat_frac);     // same as squared_cylinder()
    body_half_x = rect_w/2;

    // Place so the connector's inner face penetrates the body by ov.
    // Inner face x = x_center - connector_len/2 = body_half_x - ov
    x_center = body_half_x + connector_len/2 - ov;

    translate([x_center, connector_offset_y, connector_offset_z])
        cube([connector_len, connector_w, connector_h], center=true);
}

module mount_holes_subtract() {
    // Through holes in flange (subtracted)
    zc = motor_len/2 - front_flange_thk/2 + ov/2;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_pitch_x/2, sy*mount_hole_pitch_y/2, zc])
            cylinder(d=mount_hole_d, h=mount_hole_depth, center=true);
    }
}

// -------------------- Assembly --------------------
module servo_motor() {
    difference() {
        union() {
            motor_body();
            front_flange();
            front_pilot();
            output_shaft();
            rear_boss();
            connector_block();
        }
        mount_holes_subtract();
    }
}

servo_motor();