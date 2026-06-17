$fn = 128;

// Heat-set insert (approximation)
// Outer diameter: 4.0 mm
// Length: 6.3 mm
// Internal thread: for M4 screw (modeled as a clearance/tap hole cylinder)

od = 4.0;
len = 6.3;

// Typical M4 internal thread minor diameter is ~3.3 mm; for a printable model,
// use a slightly larger bore to represent the threaded hole.
id = 3.3;

// Small lead-in chamfers
ch = 0.35;

// Knurl approximation: shallow circumferential grooves
groove_depth = 0.18;
groove_pitch = 0.55;
groove_count = floor((len - 2*ch) / groove_pitch);

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main cylinder
            translate([0,0,ch])
                cylinder(h = len - 2*ch, d = od);

            // Bottom chamfer
            cylinder(h = ch, d1 = od - 2*ch, d2 = od);

            // Top chamfer
            translate([0,0,len - ch])
                cylinder(h = ch, d1 = od, d2 = od - 2*ch);
        }

        // Internal bore (represents threaded hole)
        translate([0,0,-0.2])
            cylinder(h = len + 0.4, d = id);

        // Circumferential grooves (knurl-like)
        for (i = [0 : groove_count - 1]) {
            z0 = ch + (i + 0.5) * groove_pitch;
            translate([0,0,z0])
                rotate_extrude()
                    translate([od/2 - groove_depth, 0, 0])
                        square([groove_depth, 0.22], center=false);
        }
    }
}

insert_body();