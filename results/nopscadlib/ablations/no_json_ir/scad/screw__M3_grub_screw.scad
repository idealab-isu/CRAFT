// M3 grub (set) screw with external thread + internal hex socket
// One connected solid (thread + tip) with socket cut out via difference()

// -------- Parameters --------
d_nom        = 3;      // M3 major diameter (approx)
length       = 10;     // overall length
pitch        = 0.5;    // M3 coarse pitch
thread_depth = 0.18;   // radial thread height (visual/printable)
tip_type     = "flat"; // "flat" or "pointed"

// Hex socket (typical M3 grub uses 1.5mm hex key)
hex_af       = 1.5;    // across flats
socket_depth = 2.2;    // depth of socket

// Detail / quality
$fn = 96;

// -------- Helpers --------
function hex_circumradius_from_af(af) = af / sqrt(3); // for regular hex

module hex_prism(af, h, center=false) {
    r = hex_circumradius_from_af(af);
    cylinder(r=r, h=h, $fn=6, center=center);
}

// External thread approximation using helical twist of a triangular ridge
module external_thread(d_major, L, P, depth) {
    r_major = d_major/2;
    r_root  = r_major - depth;

    turns = L / P;
    twist_deg = 360 * turns;

    // Root cylinder + helical ridge (unioned => one solid)
    union() {
        cylinder(r=r_root, h=L, center=false);

        // Helical ridge: extrude a small triangular profile at radius r_root
        linear_extrude(height=L, twist=twist_deg, slices=max(ceil(turns*24), 60), convexity=10)
            translate([r_root, 0, 0])
                polygon(points=[
                    [0, -P*0.22],
                    [depth, 0],
                    [0,  P*0.22]
                ]);
    }
}

// Tip geometry (kept connected by being part of the same union)
module tip_geometry(d_major, P, type) {
    if (type == "flat") {
        // Slight chamfer at the end
        chamfer_h = max(0.25, P*0.35);
        cylinder(d1=d_major, d2=d_major - 2*thread_depth, h=chamfer_h, center=false);
    } else if (type == "pointed") {
        // Cone point
        cone_h = max(1.2, P*2.2);
        cylinder(d1=d_major, d2=0, h=cone_h, center=false);
    }
}

// -------- Main model --------
module grub_screw() {
    r_major = d_nom/2;
    r_root  = r_major - thread_depth;

    // Keep overall length = length
    // For pointed tip, allocate some length to the cone; for flat, small chamfer.
    tip_h = (tip_type == "pointed") ? max(1.2, pitch*2.2) : max(0.25, pitch*0.35);
    thread_L = max(length - tip_h, pitch*2);

    difference() {
        union() {
            // Threaded body from z=0..thread_L
            external_thread(d_nom, thread_L, pitch, thread_depth);

            // Tip from z=thread_L..length (connected)
            translate([0, 0, thread_L])
                tip_geometry(d_nom, pitch, tip_type);
        }

        // Hex socket cut from the top face downward (connected cut, not floating)
        // Slightly oversize for printability
        socket_af = hex_af + 0.15;
        socket_r  = hex_circumradius_from_af(socket_af);

        translate([0, 0, length - socket_depth])
            hex_prism(socket_af, socket_depth + 0.2, center=false);

        // Small lead-in chamfer for the socket opening
        translate([0, 0, length - 0.6])
            cylinder(r1=socket_r*1.15, r2=socket_r, h=0.6, center=false, $fn=48);
    }
}

// Render
grub_screw();