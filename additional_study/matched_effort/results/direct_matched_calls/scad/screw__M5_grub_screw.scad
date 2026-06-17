$fn = 96;

// M5 grub screw (set screw) approximation
// Parameters (mm)
d_major = 5.0;          // thread major diameter
pitch   = 0.8;          // M5 coarse pitch
len     = 10.0;         // overall length
hex_af  = 2.5;          // internal hex across flats (common for M5 grub)
hex_depth = 3.0;        // depth of hex socket
chamfer = 0.4;          // end chamfer
thread_depth = 0.35;    // radial thread depth (approx)
crest_flat = 0.12;      // small flattening at crest/root

module hex_socket(af=2.5, depth=3.0) {
    // Hex prism sized by across-flats
    r = af / (2*cos(30));
    linear_extrude(height=depth, center=false)
        polygon([ for (i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module helical_thread(d=5, p=0.8, L=10, depth=0.35, crest=0.12) {
    // Create an external thread by sweeping a triangular-ish profile around Z
    // using linear_extrude with twist.
    turns = L / p;
    twist_deg = 360 * turns;

    // Profile in (x,y) plane, then extruded along Z with twist.
    // Place profile near radius d/2.
    R = d/2;

    // A simple trapezoid-ish profile approximating ISO metric thread
    // centered around the pitch line.
    // y is radial direction; x is along pitch direction (one pitch wide).
    w = p;
    y0 = R - depth;          // root radius
    y1 = R - crest;          // near crest
    y2 = R;                  // crest radius

    // Slightly flattened crest/root
    profile = [
        [0.00*w, y0],
        [0.20*w, y0],
        [0.50*w, y2],
        [0.80*w, y0],
        [1.00*w, y0],
        [1.00*w, y1],
        [0.80*w, y1],
        [0.50*w, y2 - crest],
        [0.20*w, y1],
        [0.00*w, y1]
    ];

    // Sweep around Z: translate profile so x maps to angle via twist
    // We position the profile at +X by rotating the whole extrude later.
    rotate([0,0,0])
    linear_extrude(height=L, twist=twist_deg, slices=max(ceil(turns*40), 80), convexity=10)
        polygon(profile);
}

module grub_screw() {
    difference() {
        union() {
            // Core cylinder slightly under major diameter to avoid overly sharp thread
            cylinder(h=len, d=d_major - 2*thread_depth*0.6);

            // External thread
            // Shift thread profile so it wraps around the cylinder:
            // We rotate the swept profile around Z by 90deg and translate so its radial axis aligns.
            // The profile uses y as radius; we need it centered at origin already.
            // The polygon is defined in x (pitch) and y (radius), so it already sits at correct radius.
            // But it is not centered at origin in x; that's fine for twist extrusion.
            // Rotate so the "radius" axis points outward from origin.
            rotate([0,0,0])
                helical_thread(d=d_major, p=pitch, L=len, depth=thread_depth, crest=crest_flat);
        }

        // Internal hex socket at top
        translate([0,0,len-hex_depth])
            hex_socket(af=hex_af, depth=hex_depth + 0.2);

        // Chamfer both ends
        // Top chamfer
        translate([0,0,len-chamfer])
            cylinder(h=chamfer+0.01, d1=d_major+0.6, d2=d_major-0.2);

        // Bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=chamfer+0.02, d1=d_major-0.2, d2=d_major+0.6);
    }
}

grub_screw();