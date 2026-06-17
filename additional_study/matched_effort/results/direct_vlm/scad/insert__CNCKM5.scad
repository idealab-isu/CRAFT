$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 5.8 mm
// Length: 7.1 mm
// For 5.0 mm screws (internal thread approximated as clearance bore)

od = 5.8;
len = 7.1;

// Typical M5 clearance is ~5.2; use 5.1 to be slightly snug in model
id = 5.1;

// Small lead-in chamfers
chamfer = 0.5;

// Optional shallow knurl-like rings (visual/approx grip)
ring_count = 8;
ring_depth = 0.25;
ring_width = 0.45;

module insert_body() {
    difference() {
        union() {
            // Main cylinder
            cylinder(d=od, h=len);

            // Add shallow rings for grip
            for (i = [0:ring_count-1]) {
                z = (i + 0.5) * (len / ring_count);
                translate([0,0,z - ring_width/2])
                    cylinder(d=od + 2*ring_depth, h=ring_width);
            }
        }

        // Internal bore
        translate([0,0,-0.1])
            cylinder(d=id, h=len + 0.2);

        // Chamfer both ends (subtract cones)
        translate([0,0,-0.01])
            cylinder(d1=id + 2*chamfer, d2=id, h=chamfer + 0.02);

        translate([0,0,len - chamfer - 0.01])
            cylinder(d1=id, d2=id + 2*chamfer, h=chamfer + 0.02);
    }
}

insert_body();