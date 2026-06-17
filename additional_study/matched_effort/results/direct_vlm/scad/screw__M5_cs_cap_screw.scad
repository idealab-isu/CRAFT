$fn = 128;

// Socket head cap screw (ISO 4762-like)
// Required: shank diameter = 5.0mm, head diameter = 10.0mm, length under head = 10.0mm

d_shank = 5.0;
d_head  = 10.0;
L       = 10.0;   // length under head

// Typical M5 socket head proportions (approx)
k_head      = 5.0;   // head height
hex_af      = 4.0;   // internal hex across flats
hex_depth   = 3.0;   // socket depth
head_chamfer = 0.5;  // edge chamfer on head
tip_chamfer  = 0.6;  // chamfer at screw tip

// Simple cosmetic thread (not ISO-accurate), but visibly threaded
pitch        = 0.8;   // M5 coarse pitch
thread_depth = 0.35;  // radial depth of thread
thread_len   = L;     // fully threaded under head

eps = 0.02;

module hex_prism(af, h) {
    // Regular hex with given across-flats (af)
    // circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module chamfered_cylinder(h, d, chamfer=0.5) {
    c = min(chamfer, h/2);
    union() {
        translate([0,0,c]) cylinder(h=h-2*c, d=d);
        cylinder(h=c, d1=d-2*c, d2=d);
        translate([0,0,h-c]) cylinder(h=c, d1=d, d2=d-2*c);
    }
}

module helical_thread(d_major, pitch, depth, len) {
    // Creates a visible helical ridge by sweeping a small triangular profile
    // around the cylinder using linear_extrude with twist.
    turns = len / pitch;
    r0 = d_major/2 - depth;          // inner radius of ridge
    w  = pitch * 0.55;               // profile width along tangential direction

    // Triangular profile in XY, placed at radius r0 and swept helically
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([r0, 0, 0])
            polygon(points=[
                [0, -w/2],
                [depth, 0],
                [0,  w/2]
            ]);
}

module screw() {
    difference() {
        union() {
            // Threaded shank (connected to head)
            union() {
                // Core cylinder slightly under major diameter so thread ridge defines major OD
                cylinder(h=L, d=d_shank - 2*thread_depth);

                // Helical ridge (thread)
                helical_thread(d_major=d_shank, pitch=pitch, depth=thread_depth, len=thread_len);

                // Tip chamfer (kept within shank length; overlaps for watertight union)
                cylinder(h=tip_chamfer, d1=max(d_shank - 2*tip_chamfer, 0.1), d2=d_shank);
            }

            // Head sits directly on top of shank: z = L
            translate([0,0,L - eps])
                chamfered_cylinder(h=k_head + eps, d=d_head, chamfer=head_chamfer);
        }

        // Internal hex socket recessed into head from the top face
        translate([0,0, L + k_head - hex_depth])
            hex_prism(hex_af, hex_depth + 0.2);
    }
}

screw();