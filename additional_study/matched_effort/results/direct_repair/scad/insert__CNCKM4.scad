$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 4.0 mm
// Length: 6.3 mm
// Internal thread: for M4 screw (modeled as a clearance/tap bore, not true helical threads)

od = 4.0;
len = 6.3;

// Typical M4 internal minor diameter for a heat-set insert is around 3.2–3.4 mm.
// Use 3.3 mm as a reasonable approximation.
id = 3.3;

// Small lead-in chamfers
chamfer = 0.35;

// Optional shallow knurl-like rings to suggest heat-set insert texture
ring_count = 10;
ring_depth = 0.18;
ring_width = 0.35;

module insert_body() {
    difference() {
        // Outer body
        cylinder(h = len, d = od);

        // Inner bore
        translate([0,0,-0.01])
            cylinder(h = len + 0.02, d = id);

        // Chamfer top (remove material)
        translate([0,0,len - chamfer])
            difference() {
                cylinder(h = chamfer + 0.02, d = od + 0.02);
                translate([0,0,-0.01])
                    cylinder(h = chamfer + 0.04, d1 = od - 2*chamfer, d2 = od + 0.02);
            }

        // Chamfer bottom (remove material)
        translate([0,0,0])
            difference() {
                cylinder(h = chamfer + 0.02, d = od + 0.02);
                translate([0,0,-0.01])
                    cylinder(h = chamfer + 0.04, d1 = od + 0.02, d2 = od - 2*chamfer);
            }

        // Shallow circumferential grooves (knurl/rings)
        for (i = [0:ring_count-1]) {
            z0 = chamfer + (len - 2*chamfer) * (i + 0.5) / ring_count - ring_width/2;
            translate([0,0,z0])
                difference() {
                    cylinder(h = ring_width, d = od + 0.02);
                    translate([0,0,-0.01])
                        cylinder(h = ring_width + 0.02, d = od - 2*ring_depth);
                }
        }
    }
}

insert_body();