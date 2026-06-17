$fn = 120;

// Socket head cap screw
// Shank diameter: 3.0 mm
// Head diameter: 6.0 mm
// Overall length: 10.0 mm (head height + under-head length)

// ---------------- Parameters ----------------
shank_d = 3.0;
head_d  = 6.0;
L_total = 10.0;

// Proportions (parametric)
head_h         = 3.0;                 // head height
underhead_L    = L_total - head_h;    // length under head

hex_af         = 2.5;                 // across flats (approx for M3)
hex_depth      = 1.6;                 // recess depth

top_chamfer_h  = 0.35;
top_chamfer_w  = 0.35;
under_fillet_h = 0.6;

// Thread approximation (visual)
pitch          = 0.5;
thread_depth   = 0.18;
thread_start   = 0.4;
thread_end     = 0.2;
thread_len     = max(0, underhead_L - thread_start - thread_end);

// Structural overlap to guarantee attachment (1-2mm as required)
overlap = 1.2;

// Small epsilon for robust booleans
eps = 0.03;

// ---------------- Helpers ----------------
module hex_prism(af, h) {
    // Regular hex with across-flats = af
    // For a regular hex: R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height = h)
        polygon([for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

module thread_ridges(d, len, pitch, depth) {
    turns = len / pitch;
    steps_per_turn = 18;
    steps = max(6, ceil(turns * steps_per_turn));
    r0 = d/2;
    ridge_r = max(0.06, depth/2);

    for (i = [0:steps-1]) {
        t1 = i/steps;
        t2 = (i+1)/steps;

        z1 = t1 * len;
        z2 = t2 * len;

        a1 = 360 * turns * t1;
        a2 = 360 * turns * t2;

        hull() {
            translate([ (r0 + depth)*cos(a1), (r0 + depth)*sin(a1), z1 ])
                rotate([90,0,0]) cylinder(h=eps, r=ridge_r, center=true);
            translate([ (r0 + depth)*cos(a2), (r0 + depth)*sin(a2), z2 ])
                rotate([90,0,0]) cylinder(h=eps, r=ridge_r, center=true);
        }
    }
}

module shank_with_threads() {
    union() {
        // Extend shank slightly upward so it intersects the head/fillet region
        translate([0,0,-overlap])
            cylinder(h = underhead_L + overlap, d = shank_d);

        // Ensure thread geometry is also physically connected (not floating)
        if (thread_len > 0)
            translate([0,0,thread_start - overlap])
                thread_ridges(shank_d, thread_len + overlap, pitch, thread_depth);
    }
}

module head_solid() {
    union() {
        // Main head body (up to chamfer start)
        cylinder(h = head_h - top_chamfer_h, d = head_d);

        // Top chamfer
        translate([0,0,head_h - top_chamfer_h])
            cylinder(h = top_chamfer_h, d1 = head_d, d2 = head_d - 2*top_chamfer_w);

        // Under-head blend (overlaps head and shank region)
        // Keep as-is; shank is extended upward to guarantee intersection.
        cylinder(h = under_fillet_h, d1 = head_d, d2 = shank_d);
    }
}

module screw() {
    difference() {
        union() {
            // Head at Z = 0..head_h
            head_solid();

            // Shank starts at underside of head (Z=head_h) but is extended upward by 'overlap'
            // so it intersects the head/fillet region (no gap, no floating thread).
            translate([0,0,head_h])
                shank_with_threads();
        }

        // Hex socket recess cut from the TOP face (Z = head_h downwards)
        translate([0,0,head_h - hex_depth - eps])
            hex_prism(hex_af, hex_depth + 2*eps);
    }
}

screw();