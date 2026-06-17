$fn = 120;

// Heat-set insert (approximation)
// Outer: 8.0mm OD, 6.0mm long
// Internal thread: for M3 screw (modeled as a simple clearance/tap bore)

od = 8.0;
len = 6.0;

// Typical M3 internal thread minor diameter is ~2.5mm; for a printable model,
// use a slightly larger bore to ensure renderability and practical fit.
bore_d = 2.6;

// Optional lead-in chamfers
chamfer = 0.4;

// Simple knurl-like rings to mimic heat-set insert texture
ring_count = 10;
ring_depth = 0.35;
ring_width = len / (ring_count * 2);

module insert_body() {
    difference() {
        // Outer body with small end chamfers
        union() {
            // Main cylinder
            cylinder(d=od, h=len);

            // Add subtle ring ridges (approximation)
            for (i = [0:ring_count-1]) {
                z0 = (i + 0.5) * (len / ring_count);
                translate([0,0,z0 - ring_width/2])
                    cylinder(d=od + 2*ring_depth, h=ring_width);
            }
        }

        // Bore
        translate([0,0,-0.1])
            cylinder(d=bore_d, h=len + 0.2);

        // Chamfers (subtract cones)
        if (chamfer > 0) {
            // Top chamfer
            translate([0,0,len - chamfer])
                cylinder(d1=bore_d, d2=bore_d + 2*chamfer, h=chamfer + 0.01);

            // Bottom chamfer
            translate([0,0,-0.01])
                cylinder(d1=bore_d + 2*chamfer, d2=bore_d, h=chamfer + 0.02);
        }
    }
}

insert_body();