$fn = 96;

// M4 grub screw (set screw) approximation with hex socket.
// Dimensions are typical; adjust as needed.
d_thread = 4.0;          // major diameter
pitch = 0.7;             // M4 coarse
len = 8.0;               // length (mm)
socket_af = 2.0;         // hex key size across flats (typical for M4)
socket_depth = 2.5;      // socket depth
tip_cone_h = 1.2;        // cone point height
chamfer_h = 0.4;         // top chamfer height

// --- helpers ---
module hex_prism(af, h) {
    // Regular hex with given across-flats
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module helical_thread(d_major, p, L, depth=0.22, starts=1) {
    // Lightweight external thread approximation using a triangular profile
    // swept with linear_extrude twist.
    // depth ~ thread height (radial). For M4x0.7, ~0.22-0.28 looks OK visually.
    turns = L / p;
    r_major = d_major/2;
    r_root  = r_major - depth;

    // 2D profile in XY: a small triangle near the outer radius
    // positioned so that its outermost point touches r_major.
    module profile2d() {
        // Triangle points (x=radius, y=along pitch direction)
        // Keep it narrow to avoid self-intersection.
        polygon(points=[
            [r_root, -p*0.18],
            [r_major, 0],
            [r_root,  p*0.18]
        ]);
    }

    // Create one-start thread; for multiple starts, rotate copies.
    for (s = [0:starts-1]) {
        rotate([0,0,360*s/starts])
            linear_extrude(height=L, twist=360*turns, slices=max(ceil(turns*24), 60), convexity=10)
                profile2d();
    }
}

module grub_screw_M4(L=len) {
    union() {
        // Core cylinder slightly under major diameter so thread adds up
        core_d = d_thread - 2*0.18;
        cylinder(h=L, d=core_d);

        // Thread
        helical_thread(d_major=d_thread, p=pitch, L=L, depth=0.22, starts=1);

        // Tip: cone point
        translate([0,0,0])
            cylinder(h=tip_cone_h, r1=d_thread/2, r2=0);

        // Top chamfer (small)
        translate([0,0,L-chamfer_h])
            cylinder(h=chamfer_h, r1=d_thread/2, r2=(d_thread/2 - chamfer_h));
    }
}

difference() {
    // Body
    grub_screw_M4(len);

    // Hex socket cut from top
    translate([0,0,len - socket_depth])
        hex_prism(socket_af, socket_depth + 0.2);

    // Slight lead-in chamfer for socket
    translate([0,0,len - socket_depth - 0.01])
        cylinder(h=0.6, r1=(socket_af/sqrt(3))*1.05, r2=(socket_af/sqrt(3))*0.95, $fn=6);
}