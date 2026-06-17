$fn=160;

// Heat-set insert (simplified) for M5 screw
// Outer diameter: 12.0mm
// Length: 10.0mm
// Internal thread: approximated as M5x0.8 (modeled as helical cut)

od = 12.0;
len = 10.0;

m_nom = 5.0;          // nominal screw diameter
pitch = 0.8;          // typical M5 coarse pitch
thread_depth = 0.35;  // radial depth of internal thread (approx)
minor_d = m_nom - 2*thread_depth; // approximate minor diameter for internal thread

// Lead-in chamfers
chamfer = 0.6;

// Knurling (simple axial ribs approximation)
knurl_count = 24;
knurl_depth = 0.35;
knurl_width = 0.9;

// Thread modeling resolution
slices_per_turn = 28;

module internal_thread(d_minor, d_major, p, L) {
    // Creates a helical "tooth" volume to subtract from a pilot hole,
    // approximating an internal ISO metric thread.
    turns = L / p;
    steps = max(ceil(turns * slices_per_turn), 10);
    dz = L / steps;
    twist_total = -360 * turns; // negative for internal thread cut

    // Tooth profile: a small triangular wedge at radius ~ d_major/2
    // Positioned so it cuts into the hole wall.
    tooth_h = (d_major - d_minor) / 2;
    tooth_w = 0.55 * p;

    translate([0,0,0])
    linear_extrude(height=L, twist=twist_total, slices=steps, convexity=10)
        translate([d_minor/2, 0, 0])
            polygon(points=[
                [0, -tooth_w/2],
                [tooth_h, 0],
                [0,  tooth_w/2]
            ]);
}

module insert_body() {
    // Base cylinder
    difference() {
        union() {
            // Main outer cylinder
            cylinder(d=od, h=len);

            // Simple knurl ribs (axial)
            for (i = [0:knurl_count-1]) {
                rotate([0,0, i*360/knurl_count])
                    translate([od/2 - knurl_depth/2, 0, 0])
                        cube([knurl_depth, knurl_width, len], center=true);
            }
        }

        // Chamfer ends (outer)
        translate([0,0,-0.01])
            cylinder(d1=od+2*chamfer, d2=od, h=chamfer+0.02);
        translate([0,0,len-chamfer-0.01])
            cylinder(d1=od, d2=od+2*chamfer, h=chamfer+0.02);
    }
}

module insert() {
    difference() {
        insert_body();

        // Pilot hole (minor diameter) through
        translate([0,0,-0.2])
            cylinder(d=minor_d, h=len+0.4);

        // Thread cut volume (slightly larger major diameter for clearance)
        // Major diameter approximated near nominal (M5)
        translate([0,0,0])
            internal_thread(d_minor=minor_d, d_major=m_nom, p=pitch, L=len);

        // Lead-in chamfers for the internal hole
        translate([0,0,-0.01])
            cylinder(d1=minor_d+2*chamfer, d2=minor_d, h=chamfer+0.02);
        translate([0,0,len-chamfer-0.01])
            cylinder(d1=minor_d, d2=minor_d+2*chamfer, h=chamfer+0.02);
    }
}

insert();