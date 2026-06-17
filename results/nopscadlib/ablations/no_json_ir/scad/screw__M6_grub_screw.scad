// M6 grub screw (set screw) with visible threads, internal hex drive, and cup point
// All dimensions in mm

$fn = 96;

// ---- Parameters ----
shaft_diameter = 6;          // Major diameter (M6)
shaft_length   = 12;         // Overall length

// Thread (approx ISO M6x1 visual model)
pitch          = 1.0;        // M6 coarse pitch
thread_depth   = 0.55;       // radial depth (visual)
minor_diameter = shaft_diameter - 2*thread_depth;

// Internal hex socket (approx for M6 set screw)
hex_af         = 3.0;        // across flats
socket_depth   = 3.0;        // depth of hex recess

// Cup point
cup_depth      = 0.7;        // depth of concave cup
cup_diameter   = 3.6;        // diameter of cup opening

// Small overlaps to ensure watertight unions/differences
eps = 0.02;

// ---- Helpers ----
function hex_circumradius_from_af(af) = af / sqrt(3); // R such that across flats = af

module hex_prism(af, h) {
    cylinder(h=h, r=hex_circumradius_from_af(af), $fn=6);
}

// Helical thread as a triangular ridge wrapped around the shaft
module helical_thread(major_d, minor_d, pitch, length) {
    turns = length / pitch;
    r_minor = minor_d/2;
    r_major = major_d/2;

    // 2D profile in X-Y for rotate_extrude: a small triangle at radius r_minor..r_major
    // Then twist it along Z with linear_extrude to create a helix.
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
        translate([r_minor, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [r_major - r_minor, 0],
                [0,  pitch*0.22]
            ]);
}

module threaded_body() {
    union() {
        // Core cylinder at minor diameter
        cylinder(d=minor_diameter, h=shaft_length, center=false);

        // Add helical ridge to reach major diameter
        helical_thread(shaft_diameter, minor_diameter, pitch, shaft_length);
    }
}

module hex_socket_cut() {
    // Cut from the "top" end (z = shaft_length)
    translate([0, 0, shaft_length - socket_depth])
        hex_prism(hex_af, socket_depth + eps);
}

module cup_point_cut() {
    // Concave spherical cup at the "bottom" end (z = 0)
    // Sphere center placed so it creates a shallow cup.
    // Ensure it doesn't remove too much material.
    r = cup_diameter/2;
    translate([0, 0, cup_depth - r])
        sphere(r=r, $fn=96);
}

module grub_screw() {
    difference() {
        threaded_body();
        hex_socket_cut();
        cup_point_cut();
    }
}

// Render
grub_screw();