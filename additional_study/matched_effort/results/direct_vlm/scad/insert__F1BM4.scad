$fn = 180;

// Threaded heat-set insert for M4 screw
// Target: OD 8.2mm, length 6.3mm, internal M4 thread (modeled), knurled/barbed OD, end chamfers

outer_d = 8.2;
length  = 6.3;

// M4 internal thread (approx ISO metric)
thread_major_d = 4.0;   // nominal major diameter
thread_pitch   = 0.7;   // M4 coarse
thread_depth   = 0.30;  // radial depth approximation (visual + printable)

// Lead-in chamfers
end_chamfer   = 0.45;   // outer chamfer height
inner_chamfer = 0.45;   // inner chamfer height

// Knurling / barbs (diamond-ish via crossed helical ribs)
knurl_height = 0.35;    // radial protrusion
knurl_pitch  = 1.10;    // axial pitch of ribs
knurl_count  = 18;      // number of ribs per direction
knurl_rib_w  = 0.55;    // rib thickness

eps = 0.02;

module helical_rib(r_base, h, rib_w, twist_deg) {
    // A thin rectangular rib extruded with twist around Z
    linear_extrude(height=h, twist=twist_deg, slices=max(24, ceil(h*16)), convexity=10)
        translate([r_base, -rib_w/2])
            square([knurl_height + eps, rib_w], center=false);
}

module knurled_outer() {
    r_base = outer_d/2 - knurl_height; // ribs protrude to reach outer_d/2
    twist_amt = 360*length/knurl_pitch;

    union() {
        // Core cylinder up to base radius (so ribs add to reach outer_d)
        cylinder(r=r_base, h=length, center=false);

        // Crossed helical ribs (diamond-like)
        for (i = [0:knurl_count-1]) {
            a = i * 360/knurl_count;

            rotate([0,0,a])
                helical_rib(r_base=r_base, h=length, rib_w=knurl_rib_w, twist_deg= twist_amt);

            rotate([0,0,a + 180/knurl_count])
                helical_rib(r_base=r_base, h=length, rib_w=knurl_rib_w, twist_deg=-twist_amt);
        }
    }
}

module outer_with_end_chamfers() {
    // Chamfer both ends without changing max OD (still outer_d)
    intersection() {
        knurled_outer();

        union() {
            // Middle straight section
            translate([0,0,end_chamfer])
                cylinder(d=outer_d, h=max(eps, length - 2*end_chamfer), center=false);

            // Bottom chamfer
            cylinder(d1=outer_d - 2*end_chamfer, d2=outer_d, h=end_chamfer, center=false);

            // Top chamfer
            translate([0,0,length - end_chamfer])
                cylinder(d1=outer_d, d2=outer_d - 2*end_chamfer, h=end_chamfer, center=false);
        }
    }
}

module internal_threaded_hole() {
    // Internal thread approximated by subtracting a twisted triangular profile.
    // Ensure a real through-hole by subtracting a slightly larger minor cylinder.
    minor_d = thread_major_d - 2*thread_depth;

    // Through-hole (minor diameter) - MUST be longer than body to avoid "capped" ends in some views
    translate([0,0,-2*eps])
        cylinder(d=minor_d, h=length + 4*eps, center=false);

    // Helical "thread groove" subtraction
    twist_deg = 360*(length/thread_pitch);

    translate([0,0,-2*eps])
        linear_extrude(
            height=length + 4*eps,
            twist=twist_deg,
            slices=max(48, ceil((length/thread_pitch)*48)),
            convexity=10
        )
            translate([minor_d/2, 0])
                polygon(points=[
                    [0, -thread_pitch*0.28],
                    [thread_depth, 0],
                    [0,  thread_pitch*0.28]
                ]);
}

difference() {
    // ONE connected solid outer body
    outer_with_end_chamfers();

    // Subtract internal threaded hole (through)
    internal_threaded_hole();

    // Inner lead-in chamfers (both ends) to help screw start
    translate([0,0,-2*eps])
        cylinder(d1=thread_major_d + 2*inner_chamfer, d2=thread_major_d, h=inner_chamfer + 4*eps, center=false);

    translate([0,0,length - inner_chamfer - 2*eps])
        cylinder(d1=thread_major_d, d2=thread_major_d + 2*inner_chamfer, h=inner_chamfer + 4*eps, center=false);
}