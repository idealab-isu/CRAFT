$fn = 128;

// Threaded heat-set insert (parametric approximation)
// Target: 5.8mm OD, 4.6mm length, internal M2.5 thread, external knurl/barbs

od  = 5.8;
len = 4.6;

// M2.5x0.45 (typical coarse pitch)
pitch = 0.45;

// Internal thread geometry (approx ISO 60°)
// Major diameter for M2.5 is 2.5mm; minor ~2.05-2.15mm.
// Use a slightly generous minor to keep the model printable/robust.
thread_major_d = 2.50;
thread_minor_d = 2.12;

// External knurl/barb geometry (subtractive grooves)
knurl_count = 24;     // around circumference
knurl_depth = 0.25;   // radial depth into OD
knurl_w     = 0.55;   // tangential width of each groove

// End chamfers
ch = 0.35;

// Small overlap to ensure watertight booleans
eps = 0.02;

function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// 60° V-thread (internal) using linear_extrude twist of a triangular "cutter"
module internal_thread(d_major, d_minor, p, h) {
    // Thread depth (radial)
    depth = (d_major - d_minor) / 2;
    // Place the cutter near the major radius so it carves the flanks
    r_major = d_major / 2;

    // Triangular profile in XY, then helical via twist
    // The triangle points inward by 'depth' and spans ~p/2 tangentially.
    linear_extrude(height = h + 2*eps, twist = -360 * (h / p), slices = max(ceil(h*24), 80), convexity = 10)
        translate([r_major - eps, 0, 0])
            polygon(points=[
                [0, -p/4],
                [-depth, 0],
                [0,  p/4]
            ]);
}

// External knurl/barbs as repeated vertical grooves cut into the OD
module external_knurl_grooves(od, h, count, depth, w) {
    r = od/2;
    for (i = [0:count-1]) {
        rotate([0,0,i*360/count])
            translate([r - depth/2, 0, h/2])
                cube([depth + eps, w, h + 2*eps], center=true);
    }
}

module heat_set_insert() {
    // Keep chamfers within length
    ch_eff = clamp(ch, 0, len/2 - 0.01);

    difference() {
        // Outer body with chamfers (single connected solid)
        union() {
            // Main cylinder section
            translate([0,0,ch_eff])
                cylinder(d=od, h=len - 2*ch_eff);

            // Bottom chamfer
            cylinder(d1=od - 2*ch_eff, d2=od, h=ch_eff);

            // Top chamfer
            translate([0,0,len - ch_eff])
                cylinder(d1=od, d2=od - 2*ch_eff, h=ch_eff);
        }

        // External knurl/barb grooves (cut into outer surface)
        // Leave a small margin near chamfers
        knurl_h = max(0.01, len - 2*ch_eff - 0.10);
        translate([0,0,ch_eff + 0.05])
            external_knurl_grooves(od=od, h=knurl_h, count=knurl_count, depth=knurl_depth, w=knurl_w);

        // Core bore to minor diameter (through)
        translate([0,0,-eps])
            cylinder(d=thread_minor_d, h=len + 2*eps);

        // Helical internal thread cut (adds visible threading)
        translate([0,0,-eps])
            internal_thread(d_major=thread_major_d, d_minor=thread_minor_d, p=pitch, h=len + 2*eps);

        // Lead-in countersinks (both ends) for easier screw start
        cs_h = 0.45;
        translate([0,0,-eps])
            cylinder(d1=thread_major_d + 0.6, d2=thread_minor_d, h=cs_h + eps);
        translate([0,0,len - cs_h])
            cylinder(d1=thread_minor_d, d2=thread_major_d + 0.6, h=cs_h + eps);
    }
}

heat_set_insert();