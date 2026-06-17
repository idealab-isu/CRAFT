// Pan head screw - dimensions in mm
// Target: shank Ø4.2, head Ø8.2, head height 3.05, overall length 10 (under-head length)

$fn = 160;

// -------- Parameters --------
shank_d = 4.2;
length  = 10.0;     // under-head length

head_d = 8.2;
head_h = 3.05;

// Pan head profile (rounded dome + small top flat)
top_flat_d = 2.2;   // small flat on top (pan head)
top_flat_h = 0.35;  // thickness of top flat
dome_h     = head_h - top_flat_h; // remaining height for dome

// Under-head fillet (small blend into shank)
under_fillet_h = 0.35;
under_fillet_r = 0.35;

// Tip chamfer
tip_chamfer_h = 0.8;

// Threads (visible, printable approximation)
thread_pitch  = 1.4;
thread_depth  = 0.30;   // radial height of ridge
thread_length = 8.8;    // threaded portion length (<= length)
thread_width  = 0.55;   // tangential width of ridge strip

// Drive recess (hex socket)
drive_hex_flat = 3.0;   // across flats
drive_recess_h = 1.8;

overlap = 0.08;

// -------- Derived --------
shank_r = shank_d/2;
head_r  = head_d/2;

z_tip       = 0;
z_underhead = length;           // underside of head
z_head_top  = length + head_h;

// -------- Helpers --------
module hex_prism(af, h) {
    r = af / sqrt(3); // circumradius from across-flats
    cylinder(h=h, r=r, $fn=6);
}

module pan_head() {
    // Rounded pan head using rotate_extrude profile (no countersink/cone look)
    // Profile is built in XZ plane at y=0, then revolved around Z.
    // Underside at z=z_underhead, top at z=z_head_top.
    union() {
        // Main dome + top flat as a single revolved profile
        translate([0,0,z_underhead])
            rotate_extrude(convexity=10)
                polygon(points=[
                    // start at axis on underside
                    [0, 0],
                    // underside outer edge
                    [head_r, 0],

                    // gentle under-head rounding up a bit (keeps pan head feel)
                    [head_r, under_fillet_h],

                    // dome curve up to start of top flat
                    [head_r*0.92, dome_h*0.55],
                    [head_r*0.70, dome_h*0.85],
                    [top_flat_d/2, dome_h],

                    // top flat
                    [top_flat_d/2, dome_h + top_flat_h],
                    [0, dome_h + top_flat_h]
                ]);

        // Under-head fillet into shank (ensures smooth transition and solid connection)
        // This is a small torus-like blend approximated by hull of two circles revolved.
        translate([0,0,z_underhead - under_fillet_h])
            rotate_extrude(convexity=10)
                polygon(points=[
                    [shank_r, 0],
                    [head_r, under_fillet_h],
                    [head_r, under_fillet_h + overlap],
                    [shank_r, overlap]
                ]);
    }
}

module shank_core() {
    // Core cylinder up to underside of head (connected with slight overlap)
    translate([0,0,z_tip])
        cylinder(h=length + overlap, r=shank_r);
}

module tip_chamfer() {
    // Conical tip at bottom (connected to shank)
    translate([0,0,z_tip])
        cylinder(h=tip_chamfer_h, r1=0, r2=shank_r);
}

module thread_ridge() {
    // Helical ridge around shank (external thread approximation)
    // Use a thin strip swept with twist; positioned so it protrudes beyond shank.
    turns = thread_length / thread_pitch;
    twist_deg = 360 * turns;

    // Start slightly above the very tip to avoid degeneracy
    z0 = tip_chamfer_h * 0.25;
    h  = min(thread_length, length - z0);

    translate([0,0,z0])
        linear_extrude(height=h, twist=twist_deg, slices=max(ceil(turns*60), 120), convexity=10)
            translate([shank_r - thread_depth/2, 0, 0])
                square([thread_depth, thread_width], center=true);
}

module screw_solid() {
    union() {
        shank_core();
        tip_chamfer();
        pan_head();
        thread_ridge();
    }
}

module drive_recess() {
    // Hex socket cut into head from top
    translate([0,0,z_head_top - drive_recess_h])
        hex_prism(drive_hex_flat, drive_recess_h + overlap*2);
}

// -------- Final --------
difference() {
    screw_solid();
    drive_recess();
}