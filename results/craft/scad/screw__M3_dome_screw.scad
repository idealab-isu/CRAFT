// Dome head screw (M3x10) with simple helical thread + hex socket
// Requested: shank dia 3.0mm, head dia 5.7mm, head height 1.65mm, overall length 10mm
// Output: ONE connected solid (single screw). No extra washer/spacer/buzzer geometry.

$fn = 96;

// --- Parameters (mm) ---
d_shank = 3.0;
L_total = 10.0;

d_head = 5.7;
h_head = 1.65;

// Thread (visual approximation)
pitch = 0.5;                 // typical M3 pitch
d_major = 3.0;
d_minor = 2.6;
thread_len = L_total - h_head;

// Hex socket (approx for M3 button/dome head)
socket_af = 2.5;             // across flats
socket_depth = 1.0;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;
overlap = 0.15;

// --- Helpers ---
function hex_R_from_AF(af) = af / (2 * cos(30)); // circumradius for hex polygon

module dome_head(d, h) {
    // Spherical cap that exactly matches base diameter d and cap height h
    // Sphere radius: R = (a^2 + h^2) / (2h), where a = d/2
    a = d/2;
    R = (a*a + h*h) / (2*h);

    // Place cap so base plane is at z=0 and top at z=h
    // Sphere center is at z = h - R
    intersection() {
        translate([0,0,h - R]) sphere(r=R);
        translate([0,0,h/2]) cylinder(r=a, h=h + eps, center=true);
    }
}

module hex_prism(af, h) {
    R = hex_R_from_AF(af);
    linear_extrude(height=h, center=true)
        polygon(points=[ for(i=[0:5]) [R*cos(60*i), R*sin(60*i)] ]);
}

module helical_thread(dmaj, dmin, len, p) {
    // Simple external thread using a triangular profile swept with linear_extrude(twist=...)
    // This is a visual/printable approximation, not a standards-accurate ISO profile.
    turns = len / p;
    r_maj = dmaj/2;
    r_min = dmin/2;
    depth = r_maj - r_min;

    union() {
        // Core at minor diameter
        translate([0,0,-len/2])
            cylinder(r=r_min, h=len);

        // Helical ridge
        translate([0,0,-len/2])
            linear_extrude(height=len, twist=360*turns, slices=max(ceil(turns*24), 24), convexity=10)
                translate([r_min, 0, 0])
                    polygon(points=[
                        [0, -p*0.22],
                        [depth, 0],
                        [0,  p*0.22]
                    ]);
    }
}

module dome_head_screw_M3x10() {
    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // head extends to +h_head
    // threaded shank extends to -thread_len
    difference() {
        union() {
            // Head
            dome_head(d_head, h_head);

            // Threaded shank (connected to head with slight overlap)
            translate([0,0,-thread_len/2 + overlap/2])
                helical_thread(d_major, d_minor, thread_len + overlap, pitch);
        }

        // Hex socket cut into head from top
        translate([0,0,h_head - socket_depth/2 + eps])
            hex_prism(socket_af, socket_depth + 2*eps);
    }
}

dome_head_screw_M3x10();