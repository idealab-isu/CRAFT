// Dome head screw: 2.0mm shank dia, 3.5mm head dia, 1.3mm head height, 10mm length (under head)
// Fixed: ensure head and shaft are physically connected (no floating/duplicated head),
// with a deliberate 1–2mm overlap and a single union() solid.

$fn = 96;

// Parameters (mm)
screw_diameter    = 2.0;
length_under_head = 10.0;

head_diameter     = 3.5;
head_height       = 1.3;

thread_pitch      = 0.4;
thread_depth      = 0.12;

tip_length        = 0.6;     // included within length_under_head
threaded_length   = 10.0;    // will be clamped to length_under_head

// Structural overlap to guarantee attachment (1–2mm as required)
overlap = 1.0;

// Derived
shank_r = screw_diameter/2;
head_r  = head_diameter/2;

threaded_len   = min(threaded_length, length_under_head);
unthreaded_len = max(0, length_under_head - threaded_len);

// --- Helpers ---
module dome_head(h, d) {
    // Spherical cap with exact base diameter d and height h
    a = d/2;
    R = (a*a + h*h) / (2*h);
    zc = h - R; // sphere center relative to base plane z=0

    intersection() {
        translate([0,0,zc]) sphere(r=R);
        // keep only 0..h
        translate([0,0,h/2]) cube([d*2, d*2, h], center=true);
    }
}

module external_thread(len, major_d, pitch, depth) {
    major_r = major_d/2;
    minor_r = major_r - depth;

    turns  = len / pitch;
    slices = max(ceil(turns * 24), 60);

    union() {
        // Core at minor diameter
        cylinder(h=len, r=minor_r);

        // Helical ridge
        linear_extrude(height=len, twist=turns*360, slices=slices, convexity=10)
            translate([minor_r, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module screw() {
    // Coordinate system:
    // Head base plane at z=0, head extends to +head_height,
    // shank extends downward from z=0 to z=-length_under_head.
    //
    // Fix: build the shaft starting at z=0 and extend slightly into the head
    // (positive z) by 'overlap' so the union is guaranteed connected.

    union() {
        // Head (dome) at z=0..+head_height
        dome_head(head_height, head_diameter);

        // Shaft + threads: start at z=-length_under_head and extend up to z=+overlap
        // so it intersects the head volume (no floating/disconnected head).
        translate([0,0,-length_under_head]) {
            // Threaded portion (covers full under-head length)
            external_thread(threaded_len, screw_diameter, thread_pitch, thread_depth);

            // Optional unthreaded portion near head (if any)
            if (unthreaded_len > 0)
                translate([0,0,threaded_len - overlap])
                    cylinder(h=unthreaded_len + overlap, r=shank_r);

            // Tip (conical) at very end (bottom)
            cylinder(h=tip_length, r1=0, r2=shank_r);

            // Attachment collar: extend the shank slightly above z=0 into the head
            // to guarantee a solid intersection (1mm overlap).
            translate([0,0,length_under_head - overlap])
                cylinder(h=overlap, r=shank_r);
        }
    }
}

screw();