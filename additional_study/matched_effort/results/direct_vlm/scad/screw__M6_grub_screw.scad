$fn = 128;

// M6 grub screw (set screw), DIN 916 style (hex socket, cup point)
// Units: mm

// -------- Parameters --------
d_thread = 6.0;          // nominal major diameter
pitch    = 1.0;          // M6 coarse
len      = 12.0;         // overall length

// Hex socket (approx DIN 916 for M6: s=3mm, depth ~3mm)
hex_af    = 3.0;         // across flats
hex_depth = 3.2;

// Cup point
cup_depth = 1.2;
cup_r     = 2.2;

// Thread modeling (visual/printable)
thread_depth = 0.45;     // radial depth (more visible than before)
thread_turns = len / pitch;

// -------- Helpers --------
function hex_R_from_af(af) = af / sqrt(3); // circumradius for hex given across flats

module hex_prism(af, h){
    // Centered on Z for easier placement
    cylinder(h=h, r=hex_R_from_af(af), $fn=6, center=true);
}

module external_thread(d_major, pitch, length, depth){
    // Robust external thread: base cylinder at root + helical ridge (triangular profile)
    r_major = d_major/2;
    r_root  = r_major - depth;

    // Thread profile in XY plane (radial x, tangential y), extruded along Z with twist
    // Keep tangential width modest to avoid self-intersection
    w = 0.55 * pitch;

    union(){
        // Root cylinder ensures a solid, connected body
        cylinder(h=length, r=r_root, center=false);

        // Helical ridge
        linear_extrude(
            height=length,
            twist=360*length/pitch,
            slices=max(ceil(length*24), 200),
            convexity=10
        )
        translate([r_root, 0, 0])
            polygon(points=[
                [0,   -w/2],
                [depth, 0],
                [0,    w/2]
            ]);
    }
}

module grub_screw_M6(L=len){
    d = d_thread;

    difference(){
        // ONE connected solid: threaded body (root cylinder + ridge)
        external_thread(d_major=d, pitch=pitch, length=L, depth=thread_depth);

        // Internal hex socket on one end face (top)
        // Slightly oversize for clean boolean and visibility
        translate([0,0, L - hex_depth/2])
            hex_prism(hex_af*1.02, hex_depth + 0.2);

        // Cup point on the other end face (bottom): subtract spherical segment
        // Sphere center placed so the sagitta equals cup_depth at z=0 plane
        translate([0,0, -(cup_r - cup_depth)])
            sphere(r=cup_r, $fn=128);
    }
}

// -------- Render --------
grub_screw_M6(len);