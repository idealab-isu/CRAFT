$fn = 128;

// Parameters (mm)
shaft_d = 8.0;      // major diameter (thread OD)
length  = 10.0;     // under-head length

head_d = 14.0;
head_h = 4.4;

// Thread parameters (simple ISO-like approximation)
pitch        = 1.25;   // coarse for ~M8
thread_depth = 0.65;   // radial depth (approx)
thread_turns = length / pitch;

// Drive (simple hex socket)
socket_af = 5.0;       // across flats
socket_depth = 2.6;    // depth into head

eps = 0.02;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module external_thread(d_major, len, pitch, depth) {
    // Base cylinder at minor diameter + helical ridge to major diameter
    d_minor = d_major - 2*depth;

    union() {
        cylinder(d=d_minor, h=len);

        // Helical ridge (triangular-ish) via linear_extrude with twist
        linear_extrude(height=len, twist=360*(len/pitch), slices=max(ceil(24*(len/pitch)), 60))
            translate([d_minor/2, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module dome_head(head_d, head_h) {
    // Spherical cap with base diameter head_d and cap height head_h
    a = head_d/2;
    h = head_h;
    R = (a*a + h*h) / (2*h);
    z0 = R - h; // plane position relative to sphere center

    // Cap from z=0..h
    translate([0,0,h - R])
        intersection() {
            sphere(r=R);
            translate([0,0,z0]) cylinder(d=head_d, h=h+eps);
        }
}

module dome_head_screw(shaft_d, length, head_d, head_h) {
    difference() {
        union() {
            // Threaded shank (connected to head at z=length)
            external_thread(shaft_d, length, pitch, thread_depth);

            // Dome head sitting on top of shank
            translate([0,0,length - eps])
                dome_head(head_d, head_h);
        }

        // Hex socket drive cut into head from the top
        translate([0,0,length + head_h - socket_depth])
            hex_prism(socket_af, socket_depth + eps);
    }
}

dome_head_screw(shaft_d, length, head_d, head_h);