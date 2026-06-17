// HT 75 Pipe 1000 mm (single connected solid)

outer_diameter = 75;      // mm
wall_thickness = 3.2;     // mm
length = 1000;            // mm

socket_h = 10;            // mm (flared socket length)
flare_extra_d = 10;       // mm (increase in diameter at socket end)
lip_h = 5;                // mm (inner lip height)
eps = 0.2;                // small overlap to guarantee manifold union

inner_diameter = outer_diameter - 2 * wall_thickness;

module ht_pipe() {
    union() {
        // Main hollow pipe body
        difference() {
            cylinder(h = length, d = outer_diameter, $fn = 160);
            translate([0, 0, -eps])
                cylinder(h = length + 2*eps, d = inner_diameter, $fn = 160);
        }

        // End socket (flared) - connected by exact placement with slight overlap
        translate([0, 0, length - eps])
            difference() {
                cylinder(h = socket_h + eps, d1 = outer_diameter, d2 = outer_diameter + flare_extra_d, $fn = 160);
                translate([0, 0, -eps])
                    cylinder(h = socket_h + 3*eps, d = inner_diameter, $fn = 160);
            }

        // Inner lip ring inside the socket - connected and not floating
        translate([0, 0, length - lip_h - eps])
            difference() {
                cylinder(h = lip_h + 2*eps, d = inner_diameter, $fn = 160);
                translate([0, 0, -eps])
                    cylinder(h = lip_h + 4*eps, d = inner_diameter - 2*wall_thickness, $fn = 160);
            }
    }
}

ht_pipe();