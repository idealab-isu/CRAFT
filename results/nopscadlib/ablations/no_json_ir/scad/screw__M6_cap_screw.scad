$fn = 120;

// Parameters (mm)
shaft_diameter = 6.0;     // major diameter
shaft_length   = 10.0;    // under-head length
head_diameter  = 10.0;
head_height    = 6.0;

// Hex socket (approx for M6 SHCS)
hex_flat       = 5.0;     // across flats
socket_depth   = 3.5;

// Thread approximation
pitch          = 1.0;
thread_depth   = 0.35;    // radial depth of thread profile
thread_fn      = 24;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;

// Helpers
function hex_circum_d(af) = af / cos(30); // across-flats -> circumscribed diameter

// External thread approximation using helical twist of a triangular ridge
module external_thread(d_major, length, pitch, depth) {
    turns = length / pitch;
    r_major = d_major/2;
    r_root  = r_major - depth;

    // Root cylinder (minor diameter)
    cylinder(h=length, r=r_root, center=false);

    // Helical ridge added on top of root cylinder
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([r_root, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

// Cap head with under-head fillet and hex socket recess
module cap_head() {
    difference() {
        union() {
            // Main head
            cylinder(h=head_height, d=head_diameter, center=false);

            // Under-head fillet (taper down to shaft)
            translate([0, 0, -0.8])
                cylinder(h=0.8 + eps, d1=shaft_diameter, d2=head_diameter, center=false);
        }

        // Hex socket recess from top
        translate([0, 0, head_height - socket_depth])
            cylinder(h=socket_depth + eps, d=hex_circum_d(hex_flat), $fn=6, center=false);

        // Slight lead-in chamfer for socket
        translate([0, 0, head_height - 0.6])
            cylinder(h=0.6 + eps, d1=hex_circum_d(hex_flat)*1.06, d2=hex_circum_d(hex_flat), $fn=6, center=false);
    }
}

// Assemble screw as one connected solid
module socket_head_cap_screw() {
    union() {
        // Threaded shank (from z=0 to z=shaft_length)
        external_thread(shaft_diameter, shaft_length, pitch, thread_depth);

        // Head sits on top of shank (connected by exact translation)
        translate([0, 0, shaft_length - eps])
            cap_head();
    }
}

socket_head_cap_screw();