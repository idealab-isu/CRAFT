// Dome head screw (connected solid) with:
// shaft diameter 8.0mm, shaft length 10.0mm (under head)
// head diameter 14.0mm, head height 4.4mm
// includes visible external threads + hex socket drive

$fn = 128;

// --- Parameters ---
head_diameter = 14.0;
head_height   = 4.4;

shaft_diameter = 8.0;
shaft_length   = 10.0;

hex_socket_af   = 5.0;   // across flats (approx)
hex_socket_depth = 3.0;  // depth into head

// Thread (visual/approx) for M8-like
thread_pitch = 1.25;
thread_depth = 0.55;     // radial depth (visual)
thread_start_chamfer = 0.8;

eps = 0.02;
overlap = 0.2;

// --- Helpers ---
function R_from_sagitta(D, h) = ( (D/2)*(D/2) + h*h ) / (2*h); // sphere radius from base diameter & cap height

module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    // circumradius = af / sqrt(3)
    cylinder(h=h, r=af/sqrt(3), $fn=6, center=center);
}

module dome_head_spherical(D, h) {
    // Spherical cap: base diameter D at z=0, top at z=h
    R = R_from_sagitta(D, h);
    zc = h - R; // sphere center z
    intersection() {
        translate([0,0,zc]) sphere(r=R, $fn=160);
        translate([0,0,h/2]) cylinder(h=h, d=D, center=true, $fn=160);
    }
}

module external_thread_visual(d_major, length, pitch, depth) {
    // Simple helical ridge (visual thread), unioned to core cylinder.
    // Major diameter = d_major, minor approx = d_major - 2*depth
    turns = length / pitch;
    ridge_w = pitch * 0.45; // axial width of ridge
    ridge_h = depth;        // radial height

    union() {
        // Core (minor diameter)
        cylinder(h=length, d=d_major - 2*depth, center=false, $fn=120);

        // Helical ridge
        linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
            translate([d_major/2 - ridge_h/2, 0, 0])
                square([ridge_h, ridge_w], center=true);
    }
}

module screw() {
    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // head spans z=[0, head_height]
    // shaft spans z=[-shaft_length, 0]
    difference() {
        union() {
            // Head (dome) + slight under-head blend to shaft
            union() {
                dome_head_spherical(head_diameter, head_height);

                // Under-head transition (small conical blend) to ensure clean connection
                translate([0,0,-overlap])
                    cylinder(h=overlap + 0.8, d1=shaft_diameter, d2=head_diameter*0.92, center=false, $fn=140);
            }

            // Threaded shaft (connected to head at z=0 with overlap)
            translate([0,0,-shaft_length])
                union() {
                    // Add a small lead-in chamfer at tip
                    union() {
                        external_thread_visual(shaft_diameter, shaft_length - thread_start_chamfer, thread_pitch, thread_depth);
                        translate([0,0,shaft_length - thread_start_chamfer])
                            cylinder(h=thread_start_chamfer, d1=shaft_diameter - 2*thread_depth, d2=shaft_diameter - 2*thread_depth - 0.8, center=false, $fn=120);
                    }
                }

            // Ensure head-to-shaft connection (tiny overlap cylinder)
            translate([0,0,-overlap])
                cylinder(h=overlap*2, d=shaft_diameter - 2*thread_depth, center=false, $fn=120);
        }

        // Hex socket drive cut into head from top
        translate([0,0,head_height - hex_socket_depth + eps])
            rotate([0,0,30])
                hex_prism(hex_socket_af, hex_socket_depth + 2*eps, center=false);

        // Slight countersink at socket opening for realism
        translate([0,0,head_height - 0.6])
            cylinder(h=0.8, d1=hex_socket_af*1.15, d2=hex_socket_af*0.98, center=false, $fn=80);
    }
}

screw();