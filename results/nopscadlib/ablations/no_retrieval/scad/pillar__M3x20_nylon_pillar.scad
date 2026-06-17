$fn = 128;

// Standoff pillar: external M3 thread, 20.0mm long, 8.0mm diameter
// One connected solid, centered at origin along Z.

standoff_length   = 20.0;
standoff_diameter = 8.0;

// M3x0.5 (approx) external thread geometry
thread_major_d    = 3.0;   // major diameter
thread_pitch      = 0.5;
thread_length     = 20.0;  // full length threaded

// Practical modeling choices (visual + printable)
thread_depth      = 0.30;  // radial depth of thread (approx)
lead_in_length    = 1.0;   // chamfer length at both ends
overlap           = 0.20;  // small overlap for watertight unions

standoff_r = standoff_diameter/2;
thread_r_major = thread_major_d/2;
thread_r_minor = thread_r_major - thread_depth;

// Helical thread using linear_extrude(twist=...)
module external_thread(major_r, minor_r, pitch, len) {
    turns = len / pitch;
    // Use a small triangular profile at the major radius, extruded with twist.
    // The profile overlaps into the cylinder to ensure a single connected solid.
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*48), 48), convexity=10)
        translate([minor_r - overlap, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [major_r - (minor_r - overlap), 0],
                [0,  pitch*0.22]
            ]);
}

module lead_in_chamfer(r, h, at_top=true) {
    // Conical chamfer that trims the thread ends
    translate([0, 0, (at_top ? (thread_length/2 - h/2) : (-thread_length/2 + h/2))])
        cylinder(h=h + 2*overlap, r1=r + 0.25, r2=0, center=true);
}

module standoff() {
    union() {
        // Main 8mm body
        cylinder(h=standoff_length, r=standoff_r, center=true);

        // External threaded rod centered and fully within body length
        translate([0, 0, 0])
        difference() {
            union() {
                // Minor diameter core
                cylinder(h=thread_length, r=thread_r_minor, center=true);

                // Helical ridge to major diameter
                translate([0, 0, -thread_length/2])
                    external_thread(thread_r_major, thread_r_minor, thread_pitch, thread_length);
            }

            // Lead-in trims (top and bottom)
            lead_in_chamfer(thread_r_major + 0.2, lead_in_length, true);
            lead_in_chamfer(thread_r_major + 0.2, lead_in_length, false);
        }
    }
}

standoff();