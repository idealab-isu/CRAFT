$fn = 64;

// Solid State Relay module overall size (mm)
L = 63.0;   // length (X)
W = 45.0;   // width  (Y)
H = 23.0;   // height (Z)

eps = 0.2;

// Rounded rectangular prism (no spheres-only hull that can look ball-like in some viewers)
module rounded_box(size=[10,10,10], r=2, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx, min(sy, sz))/2 - eps);

    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
        for (x = [-1, 1], y = [-1, 1], z = [-1, 1])
            translate([x*(sx/2 - rr), y*(sy/2 - rr), z*(sz/2 - rr)])
                sphere(r=rr);
    }
}

// One connected solid SSR-like module: body + top terminal block + mounting ears
module ssr_module() {
    // Main body
    body_r = 2.0;

    // Terminal block (top)
    term_L = L * 0.92;
    term_W = W * 0.28;
    term_H = H * 0.22;
    term_r = 1.2;

    // Mounting ears (sides)
    ear_ext = 6.0;          // how far ears extend beyond body in X
    ear_W   = W * 0.55;     // ear width in Y
    ear_H   = H * 0.35;     // ear thickness in Z
    ear_r   = 1.5;

    // Small overlap to guarantee connectivity
    ov = 0.8;

    union() {
        // Body centered at origin
        rounded_box([L, W, H], r=body_r, center=true);

        // Top terminal block: sits on top face, overlaps into body by ov
        translate([0, 0, H/2 + term_H/2 - ov])
            rounded_box([term_L, term_W, term_H], r=term_r, center=true);

        // Left ear: attached to left side, overlaps into body by ov
        translate([-(L/2 + ear_ext/2 - ov), 0, -(H/2 - ear_H/2 - ov)])
            rounded_box([ear_ext, ear_W, ear_H], r=ear_r, center=true);

        // Right ear: attached to right side, overlaps into body by ov
        translate([(L/2 + ear_ext/2 - ov), 0, -(H/2 - ear_H/2 - ov)])
            rounded_box([ear_ext, ear_W, ear_H], r=ear_r, center=true);
    }
}

ssr_module();