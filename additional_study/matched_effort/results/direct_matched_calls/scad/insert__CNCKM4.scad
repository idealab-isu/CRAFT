$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 4.0 mm
// Length: 6.3 mm
// Internal thread: for M4 screw (modeled as a clearance/bore, not true helical thread)

od = 4.0;
len = 6.3;

// Typical M4 internal minor diameter for a heat-set insert is around 3.2–3.4 mm.
// Use 3.3 mm as a reasonable bore approximation.
id = 3.3;

// Small lead-in chamfers
ch = 0.35;

// Optional shallow knurl-like rings (visual/approx grip), kept subtle
ring_count = 8;
ring_depth = 0.18;
ring_width = 0.35;

module insert_body() {
    difference() {
        // Outer body
        cylinder(h = len, d = od);

        // Inner bore
        translate([0,0,-0.01])
            cylinder(h = len + 0.02, d = id);

        // Chamfer top
        translate([0,0,len - ch])
            cylinder(h = ch + 0.02, d1 = od, d2 = od - 2*ch);

        // Chamfer bottom
        translate([0,0,-0.01])
            cylinder(h = ch + 0.02, d1 = od - 2*ch, d2 = od);

        // Shallow circumferential grooves (approx knurl/rings)
        for (i = [0:ring_count-1]) {
            z0 = (len*(i+0.5)/ring_count) - ring_width/2;
            translate([0,0,z0])
                cylinder(h = ring_width, d = od + 0.02); // cut ring
        }
    }
}

module ring_cuts() {
    // Subtract grooves by removing a thin outer shell at ring positions
    // Implemented by subtracting a slightly larger cylinder and adding back core via intersection
    // Simpler: directly subtract torus-like band via difference of cylinders.
    for (i = [0:ring_count-1]) {
        z0 = (len*(i+0.5)/ring_count) - ring_width/2;
        translate([0,0,z0])
            difference() {
                cylinder(h = ring_width, d = od + 0.02);
                translate([0,0,-0.01])
                    cylinder(h = ring_width + 0.02, d = od - 2*ring_depth);
            }
    }
}

difference() {
    // Base insert with bore and chamfers
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.01]) cylinder(h = len + 0.02, d = id);

        // Chamfers
        translate([0,0,len - ch]) cylinder(h = ch + 0.02, d1 = od, d2 = od - 2*ch);
        translate([0,0,-0.01])    cylinder(h = ch + 0.02, d1 = od - 2*ch, d2 = od);
    }

    // Groove cuts
    ring_cuts();
}