$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 3.0 mm
// Length: 4.6 mm
// For M3 screw (internal thread approximated as a smooth bore)

outer_d = 3.0;
length  = 4.6;

// Typical M3 heat-set insert minor/bore diameter approximation
inner_d = 2.6;

// Optional lead-in chamfers
chamfer = 0.25;

// Knurl approximation (shallow circumferential grooves)
groove_depth = 0.15;
groove_pitch = 0.55;
groove_count = max(1, floor(length / groove_pitch));

module insert_body() {
    difference() {
        // Outer body with slight end chamfers
        union() {
            // Main cylinder
            translate([0,0,chamfer])
                cylinder(h = length - 2*chamfer, d = outer_d);

            // Bottom chamfer
            cylinder(h = chamfer, d1 = outer_d - 2*chamfer, d2 = outer_d);

            // Top chamfer
            translate([0,0,length - chamfer])
                cylinder(h = chamfer, d1 = outer_d, d2 = outer_d - 2*chamfer);
        }

        // Internal bore (thread not modeled)
        translate([0,0,-0.2])
            cylinder(h = length + 0.4, d = inner_d);

        // Circumferential grooves (knurl-like rings)
        for (i = [0:groove_count-1]) {
            z = (i + 0.5) * (length / groove_count);
            translate([0,0,z])
                rotate_extrude()
                    translate([outer_d/2 - groove_depth, 0, 0])
                        square([groove_depth, 0.25], center=false);
        }
    }
}

insert_body();