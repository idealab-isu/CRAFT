// HT 90 Pipe 500 mm (connected, hollow, with one end socket)
// Units: mm

$fn = 160;

outer_diameter = 110;      // OD
wall_thickness = 3.2;      // wall
length = 500;              // overall length
socket_length = 20;        // socket (end fitting) length
socket_expand = 10;        // OD increase at socket end (tapered)

eps = 0.2;

inner_diameter = outer_diameter - 2 * wall_thickness;

module ht_pipe() {
    difference() {
        // Outer shell: one connected solid (main + socket), with overlap
        union() {
            cylinder(h = length, d = outer_diameter, center = false);

            translate([0, 0, length - socket_length - eps])
                cylinder(h = socket_length + eps,
                         d1 = outer_diameter,
                         d2 = outer_diameter + socket_expand,
                         center = false);
        }

        // Inner bore: single subtraction through full length (covers socket too)
        translate([0, 0, -eps])
            cylinder(h = length + 2 * eps, d = inner_diameter, center = false);
    }
}

ht_pipe();