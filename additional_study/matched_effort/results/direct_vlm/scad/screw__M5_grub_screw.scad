$fn = 128;

// M5 grub screw (set screw) with visible external threads + hex socket + cup point
// Parameters (mm)
d_major   = 5.0;     // thread major diameter
pitch     = 0.8;     // M5 coarse pitch
len       = 10.0;    // overall length

hex_af    = 2.5;     // internal hex across flats (typical for M5 set screw)
hex_depth = 3.0;     // depth of hex socket

cup_depth = 0.6;     // cup point depth
cup_diam  = 3.2;     // cup point diameter

// Thread geometry (visual/printable approximation)
thread_depth = 0.35; // radial thread height
crest_flat   = 0.10; // small flat at crest to avoid razor edges
root_clear   = 0.05; // small clearance at root to avoid self-intersections
starts       = 1;

eps = 0.02;

module hex_socket(af=2.5, depth=3.0, z_top=len) {
    // Regular hex prism sized by across-flats
    r = af / (2*cos(30));
    // Cut from top face downwards; extend slightly for clean boolean
    translate([0,0,z_top - depth - eps])
        rotate([0,0,30])
            cylinder(h=depth + 2*eps, r=r, $fn=6);
}

module cup_point(depth=0.6, diam=3.2) {
    // Concave cup by subtracting a sphere segment from the bottom face (z=0)
    rim_r = diam/2;
    R = rim_r * 1.35;                 // sphere radius
    zc = -(R - depth);                // sphere center below end face so cut depth = depth
    translate([0,0,zc]) sphere(r=R);
}

module external_thread(d_major=5, pitch=0.8, length=10, depth=0.35, starts=1) {
    // Helical ridge added onto a root cylinder.
    // Use a trapezoidal-ish profile for better visibility and robustness.
    turns  = length / pitch;
    slices = max(ceil(80*turns), 60);

    r_root  = d_major/2 - depth - root_clear;
    r_crest = d_major/2 - crest_flat;

    // 2D profile in XY, extruded along Z with twist.
    // Profile is a small wedge at radius r_root..r_crest.
    // Width along Y is proportional to pitch.
    w_root  = pitch * 0.55;
    w_crest = pitch * 0.18;

    for (s=[0:starts-1]) {
        rotate([0,0,360*s/starts])
            linear_extrude(height=length, twist=360*turns, slices=slices, convexity=10)
                polygon(points=[
                    [r_root,  -w_root/2],
                    [r_crest, -w_crest/2],
                    [r_crest,  w_crest/2],
                    [r_root,   w_root/2]
                ]);
    }
}

module grub_screw() {
    r_root = d_major/2 - thread_depth - root_clear;

    difference() {
        union() {
            // Root cylinder (minor-ish diameter)
            cylinder(h=len, r=r_root);

            // Add external thread ridge up to near major diameter
            external_thread(d_major=d_major, pitch=pitch, length=len, depth=thread_depth, starts=starts);
        }

        // Internal hex socket at top
        hex_socket(af=hex_af, depth=hex_depth, z_top=len);

        // Cup point at bottom
        cup_point(depth=cup_depth, diam=cup_diam);
    }
}

grub_screw();