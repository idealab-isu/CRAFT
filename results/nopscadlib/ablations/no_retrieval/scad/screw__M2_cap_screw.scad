// Socket Head Cap Screw — 2.0mm shank dia, 3.8mm head dia, 2.0mm head height, 10mm overall length
// Includes simplified external threads (visual helical ridge) while keeping major diameter = 2.0mm.

$fn = 128;

// Parameters (mm)
shank_d = 2.0;
length  = 10.0;

head_d  = 3.8;
head_h  = 2.0;

// Internal hex socket (across flats) + depth
socket_af    = 1.5;
socket_depth = 1.2;

// Thread (visual approximation)
thread_pitch = 0.40;   // mm per turn (approx for M2)
thread_depth = 0.18;   // radial height of ridge (kept small)
thread_start = 0.35;   // unthreaded lead-in from tip
thread_end   = 0.25;   // unthreaded under-head relief

// Small edge breaks
tip_chamfer_h      = 0.35;
head_top_chamfer_h = 0.20;

// Overlap for robust booleans/unions
overlap = 0.06;

// Derived
shank_h = length - head_h;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex with given across-flats

module hex_prism(af, h) {
    R = hex_R_from_AF(af);
    linear_extrude(height=h, center=false)
        polygon(points=[ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Helical ridge thread (unioned onto a core cylinder)
// Major diameter remains shank_d; core is reduced by 2*thread_depth.
module thread_ridge(major_d, pitch, depth, h) {
    core_r = major_d/2 - depth;
    ridge_r = depth;

    // A small circular "wire" swept helically around the core
    // Using twist = 360*h/pitch to get correct pitch.
    linear_extrude(height=h, twist=360*h/pitch, slices=max(24, ceil(h/pitch*24)), center=false)
        translate([core_r, 0, 0])
            circle(r=ridge_r, $fn=24);
}

module screw_body() {
    union() {
        // Threaded shank (connected to head)
        // Core cylinder + helical ridge, both start at z=0.
        thread_h = max(0, shank_h - thread_start - thread_end);

        // Core (minor diameter)
        cylinder(h=shank_h, r=shank_d/2 - thread_depth);

        // Helical ridge (threads) placed between lead-in and under-head relief
        if (thread_h > 0)
            translate([0,0,thread_start])
                thread_ridge(shank_d, thread_pitch, thread_depth, thread_h);

        // Tip chamfer (kept within major diameter)
        cylinder(h=tip_chamfer_h, r1=0, r2=shank_d/2);

        // Head (cylindrical), connected at z=shank_h
        translate([0,0,shank_h - overlap])
            cylinder(h=head_h + overlap, r=head_d/2);

        // Head top chamfer (slight)
        translate([0,0,shank_h + head_h - head_top_chamfer_h])
            cylinder(h=head_top_chamfer_h, r1=head_d/2, r2=max(0.01, head_d/2 - head_top_chamfer_h));
    }
}

module socket_cut() {
    // Internal hex socket recessed from top face
    translate([0,0,shank_h + head_h - socket_depth])
        hex_prism(socket_af, socket_depth + overlap);
}

// Final (one connected solid)
difference() {
    screw_body();
    socket_cut();
}