$fn = 128;

// HT 40 cap (end cap) - approximate dimensions
// Typical HT DN40: OD ~ 40 mm. Cap has a socket and a closed end.
// Parameters can be adjusted as needed.

dn_od = 40.0;          // nominal pipe outside diameter
socket_clear = 0.6;    // clearance for insertion
wall = 3.0;            // cap wall thickness
socket_depth = 25.0;   // insertion depth
end_thickness = 4.0;   // thickness of closed end
outer_extra = 4.0;     // extra outer diameter beyond pipe OD (cap body)
lip_height = 3.0;      // small outer lip height
lip_extra = 2.0;       // extra diameter for lip

outer_d = dn_od + outer_extra*2;
inner_d = dn_od + socket_clear*2;

total_h = socket_depth + end_thickness + lip_height;

module ht40_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h = socket_depth + end_thickness, d = outer_d);

            // Outer lip / collar near opening
            translate([0,0,socket_depth + end_thickness - 0.01])
                cylinder(h = lip_height + 0.01, d = outer_d + lip_extra*2);
        }

        // Inner socket cavity (open end)
        translate([0,0,0])
            cylinder(h = socket_depth, d = inner_d);

        // Slight chamfer at opening (lead-in)
        translate([0,0,0])
            cylinder(h = 2.0, d1 = inner_d + 2.0, d2 = inner_d);

        // Optional inner corner relief at bottom of socket
        translate([0,0,socket_depth - 1.5])
            cylinder(h = 1.6, d1 = inner_d, d2 = inner_d + 1.5);
    }
}

ht40_cap();