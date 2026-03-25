// D-Sub style "D connector" (single connected solid)
// Render-safe: no minkowski(), no rotate_extrude misuse, moderate $fn, simplified booleans.

$fn = 32;

// ---------------- Parameters ----------------
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 18; //[9:36:1]
shell_wall_t = 1.2; //[0.6:2.4:0.1]
face_plate_t = 2; //[1:4:0.1]

pin_count = 9; //[5:25:1]
pin_d = 1; //[0.6:2:0.1]
pin_len = 6; //[3:12:0.5]
pin_pitch_x = 2.77; //[1.5:5.5:0.01]
pin_pitch_y = 2.84; //[1.5:6:0.01]
pin_row_offset_x = 1.385; //[0.5:3:0.005]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1:6:0.1]
mount_hole_d = 3.2; //[2:6:0.1]
mount_hole_spacing = 33; //[20:66:0.5]

rear_collar_d = 14; //[7:28:0.5]
rear_collar_len = 10; //[5:20:0.5]

overlap = 0.6; //[0.2:2:0.1]

shell_top_r = 6; //[3:12:0.5]
shell_bottom_flat_h = 6; //[3:12:0.5]
shell_profile_scale_x = 1; //[0.8:1.2:0.01]
shell_profile_scale_y = 1; //[0.8:1.2:0.01]

jack_screw_boss_d = 6.5; //[4:10:0.1]
jack_screw_boss_len = 5; //[3:10:0.5]
jack_screw_offset_y = 0; //[-4:4:0.5]

pin_chamfer_h = 0.6; //[0.2:1.5:0.1]

keying_notch_W = 4; //[2:8:0.5]
keying_notch_H = 2; //[1:5:0.5]
keying_notch_D = 2; //[1:5:0.5]

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// D-sub outline (2D): bottom flat + rounded top
module dsub_outline_2d(w, h, top_r, bottom_flat_h, sx=1, sy=1) {
    w2 = (w/2)*sx;
    h2 = (h/2)*sy;
    bfh = clamp(bottom_flat_h*sy, 0, h*sy);
    tr  = clamp(top_r*sy, 0.01, h2);

    pts = [
        [-w2, -h2],
        [ w2, -h2],
        [ w2, -h2 + bfh],
        [ w2 - tr,  h2 - tr],
        [-w2 + tr,  h2 - tr],
        [-w2, -h2 + bfh]
    ];

    hull() {
        polygon(points=pts);
        translate([ w2 - tr, h2 - tr]) circle(r=tr);
        translate([-w2 + tr, h2 - tr]) circle(r=tr);
    }
}

// Extruded D-shell (solid) with optional 2D rounding via offset()
module d_shell_solid(round_r=0) {
    linear_extrude(height=shell_D, center=true, convexity=10)
        (round_r > 0
            ? offset(r=round_r, $fn=24)
                dsub_outline_2d(shell_W, shell_H, shell_top_r, shell_bottom_flat_h,
                               shell_profile_scale_x, shell_profile_scale_y)
            : dsub_outline_2d(shell_W, shell_H, shell_top_r, shell_bottom_flat_h,
                             shell_profile_scale_x, shell_profile_scale_y)
        );
}

// Hollow D-shell housing (open at mating face)
module d_shell_housing() {
    inner_w = max(shell_W - 2*shell_wall_t, 1);
    inner_h = max(shell_H - 2*shell_wall_t, 1);
    inner_d = max(shell_D - 2*shell_wall_t, 1);

    difference() {
        d_shell_solid(round_r=0.5);

        // inner cavity shifted slightly rearward so front face has material for union
        translate([0, 0, shell_wall_t/2])
            linear_extrude(height=inner_d, center=true, convexity=10)
                dsub_outline_2d(inner_w, inner_h,
                                max(shell_top_r - shell_wall_t, 0.6),
                                max(shell_bottom_flat_h - shell_wall_t, 0.6),
                                shell_profile_scale_x, shell_profile_scale_y);
    }
}

// Face plate (fills the front opening area)
module mating_face_plate() {
    z = -shell_D/2 + face_plate_t/2 - overlap;
    translate([0, 0, z])
        linear_extrude(height=face_plate_t, center=true, convexity=10)
            dsub_outline_2d(shell_W - 2*shell_wall_t,
                            shell_H - 2*shell_wall_t,
                            max(shell_top_r - shell_wall_t, 0.6),
                            max(shell_bottom_flat_h - shell_wall_t, 0.6),
                            shell_profile_scale_x, shell_profile_scale_y);
}

// Keying notch cut (front)
module keying_notch_cut() {
    z = -shell_D/2 + keying_notch_D/2 - overlap;
    y = -(shell_H/2 - shell_wall_t - keying_notch_H/2);
    translate([0, y, z])
        cube([keying_notch_W, keying_notch_H, keying_notch_D + 2*overlap], center=true);
}

// Flange with "ears" (rounded rectangle) integrated at front
module flange_blank() {
    z = -shell_D/2 + flange_t/2 - overlap;
    translate([0, 0, z])
        linear_extrude(height=flange_t, center=true, convexity=10)
            offset(r=1.0, $fn=20)
                square([flange_W - 2.0, flange_H - 2.0], center=true);
}

module mount_holes() {
    z = -shell_D/2 + flange_t/2 - overlap;
    for (sx = [-1, 1]) {
        translate([sx*mount_hole_spacing/2, 0, z])
            cylinder(r=mount_hole_d/2, h=flange_t + 2*overlap, center=true, $fn=24);
    }
}

// Jack screw bosses (front side, aligned with mount holes)
module jack_screw_bosses() {
    z = -shell_D/2 + jack_screw_boss_len/2 - overlap;
    for (sx = [-1, 1]) {
        translate([sx*mount_hole_spacing/2, jack_screw_offset_y, z])
            cylinder(r=jack_screw_boss_d/2, h=jack_screw_boss_len, center=true, $fn=28);
    }
}

// Rear strain relief collar (rear side)
module rear_strain_relief_collar() {
    z = shell_D/2 + rear_collar_len/2 - overlap;
    translate([0, 0, z])
        cylinder(r=rear_collar_d/2, h=rear_collar_len, center=true, $fn=32);
}

// Pins (two-row D-sub layout derived from pin_count)
module pins() {
    top_n = ceil(pin_count/2);
    bot_n = floor(pin_count/2);

    top_span = (top_n > 1) ? (top_n - 1) * pin_pitch_x : 0;
    bot_span = (bot_n > 1) ? (bot_n - 1) * pin_pitch_x : 0;

    z_pin = -shell_D/2 - pin_len/2 + overlap;
    z_ch  = -shell_D/2 - pin_len + pin_chamfer_h/2 + overlap;

    // Top row
    for (i = [0:top_n-1]) {
        x = -top_span/2 + i*pin_pitch_x;
        translate([x,  pin_pitch_y/2, z_pin])
            cylinder(r=pin_d/2, h=pin_len, center=true, $fn=18);
        translate([x,  pin_pitch_y/2, z_ch])
            rotate([180,0,0])
                cylinder(r1=pin_d/2, r2=0, h=pin_chamfer_h, center=true, $fn=18);
    }

    // Bottom row
    for (i = [0:bot_n-1]) {
        x = -bot_span/2 + i*pin_pitch_x + pin_row_offset_x;
        translate([x, -pin_pitch_y/2, z_pin])
            cylinder(r=pin_d/2, h=pin_len, center=true, $fn=18);
        translate([x, -pin_pitch_y/2, z_ch])
            rotate([180,0,0])
                cylinder(r1=pin_d/2, r2=0, h=pin_chamfer_h, center=true, $fn=18);
    }
}

// ---------------- Complete connector (ONE connected solid) ----------------
module connector_complete() {
    union() {
        d_shell_housing();

        difference() {
            mating_face_plate();
            keying_notch_cut();
        }

        difference() {
            flange_blank();
            mount_holes();
        }

        jack_screw_bosses();
        rear_strain_relief_collar();
        pins();
    }
}

connector_complete();