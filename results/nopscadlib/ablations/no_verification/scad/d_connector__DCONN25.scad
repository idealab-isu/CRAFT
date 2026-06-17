$fn = 96;

// Parameters
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 15; //[8:30:1]
shell_wall_t = 1.5; //[0.8:3:0.1]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1:6:0.1]

hole_d = 3.2; //[2:6:0.1]
hole_spacing = 33; //[20:60:1]

overlap = 1; //[0.5:2:0.1]

pin_block_W = 22; //[11:44:1]
pin_block_H = 8; //[4:16:1]
pin_block_D = 6; //[3:12:1]

pin_d = 1.2; //[0.6:2.4:0.1]
pin_L = 5; //[2:12:0.5]
pin_pitch_x = 4.5; //[3:8:0.1]
pin_pitch_y = 2.5; //[1.5:5:0.1]

strain_relief_r = 6; //[3:12:0.5]
strain_relief_L = 10; //[5:25:1]

jack_body_d = 6; //[4:12:0.5]
jack_body_L = 8; //[4:20:1]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// D-profile in XY: flat on left, semicircle on right
module d_profile_2d(W, H) {
    W2 = max(W, H + 0.01);
    union() {
        // rectangle part (flat side)
        translate([-(W2 - H)/2, 0])
            square([W2 - H, H], center=true);
        // semicircle part (right)
        translate([(W2 - H)/2, 0])
            circle(r=H/2);
    }
}

// Outer shell as D-profile extruded along Z
module d_shell_outer() {
    linear_extrude(height=shell_D, center=true)
        d_profile_2d(shell_W, shell_H);
}

// Inner cavity: open at FRONT (negative Z), closed at back
module d_shell_inner_open_front() {
    inner_W = max(shell_W - 2*shell_wall_t, shell_H - 2*shell_wall_t + 0.01);
    inner_H = max(shell_H - 2*shell_wall_t, 0.01);

    // Make cavity longer than shell and shift it forward so it breaks through the front face
    // but leaves a back wall thickness ~shell_wall_t.
    inner_D = shell_D + 2*shell_wall_t + 0.01;
    zc = -shell_wall_t; // pushes cavity toward front (negative Z)

    translate([0, 0, zc])
        linear_extrude(height=inner_D, center=true)
            d_profile_2d(inner_W, inner_H);
}

module d_shell_body() {
    difference() {
        d_shell_outer();
        d_shell_inner_open_front();
    }
}

// Flange plate at FRONT of shell (negative Z), overlapping into shell
module flange_plate() {
    zc = -shell_D/2 - flange_t/2 + overlap;
    translate([0, 0, zc])
        cube([flange_W, flange_H, flange_t], center=true);
}

module flange_holes() {
    zc = -shell_D/2 - flange_t/2 + overlap;
    for (sx = [-1, 1]) {
        translate([sx*hole_spacing/2, 0, zc])
            cylinder(d=hole_d, h=flange_t + 2*overlap, center=true);
    }
}

// Screw jack bodies protrude forward from flange (negative Z), overlap into flange
module screw_jacks() {
    // Center so rear end overlaps into flange by "overlap"
    zc = (-shell_D/2 - flange_t) - jack_body_L/2 + overlap;
    for (sx = [-1, 1]) {
        translate([sx*hole_spacing/2, 0, zc])
            cylinder(d=jack_body_d, h=jack_body_L, center=true);
    }
}

// Pin face block sits just behind the flange, inside the shell
module pin_block() {
    // Place so its front face is slightly behind the flange inner opening
    zc = -shell_D/2 + pin_block_D/2 + overlap;
    translate([0, 0, zc])
        cube([pin_block_W, pin_block_H, pin_block_D], center=true);
}

// Pins extend forward from pin block toward the opening (negative Z)
module pins() {
    // Pin block center:
    z_pb = -shell_D/2 + pin_block_D/2 + overlap;
    // Pin block front face:
    z_pb_front = z_pb - pin_block_D/2;
    // Pins centered so they extend forward from that face, with slight overlap into block
    zc = z_pb_front - pin_L/2 + overlap;

    positions = [
        [-pin_pitch_x,   pin_pitch_y/2],
        [0,              pin_pitch_y/2],
        [ pin_pitch_x,   pin_pitch_y/2],
        [-pin_pitch_x/2, -pin_pitch_y/2],
        [ pin_pitch_x/2, -pin_pitch_y/2]
    ];

    for (p = positions) {
        translate([p[0], p[1], zc])
            cylinder(d=pin_d, h=pin_L + 2*overlap, center=true);
    }
}

// Rear strain relief exits BACK of shell (positive Z), overlapping into shell
module rear_strain_relief() {
    zc = shell_D/2 + strain_relief_L/2 - overlap;
    translate([0, 0, zc])
        cylinder(r=strain_relief_r, h=strain_relief_L, center=true);
}

// ---------- Assembly ----------
module complete_model() {
    union() {
        // Shell + flange with mounting holes cut
        difference() {
            union() {
                d_shell_body();
                flange_plate();
            }
            flange_holes();
        }

        // Front hardware (connected via overlap into flange)
        screw_jacks();

        // Pin face (connected inside shell)
        pin_block();
        pins();

        // Rear strain relief (connected to shell)
        rear_strain_relief();
    }
}

// Final Output
complete_model();