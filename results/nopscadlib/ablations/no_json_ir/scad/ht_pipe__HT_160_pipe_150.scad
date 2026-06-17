// HT 160 pipe, length 150 mm (one connected solid, hollow)

$fn = 160;

outer_diameter = 160;     // mm
wall_thickness = 3.2;     // mm
length = 150;             // mm

// Sleeve-like end rings
ring_radial = 4;          // mm (adds to radius)
ring_height = 6;          // mm
overlap = 0.5;            // mm (ensures watertight union)

module ht_pipe() {
    od = outer_diameter;
    id = outer_diameter - 2 * wall_thickness;

    ring_od = od + 2 * ring_radial;

    // Build as a single difference: outer union minus inner void
    difference() {
        union() {
            // Outer main cylinder
            cylinder(h=length, d=od, center=false);

            // Outer end rings (flanges), connected by overlap
            translate([0, 0, -ring_height + overlap])
                cylinder(h=ring_height, d=ring_od, center=false);

            translate([0, 0, length - overlap])
                cylinder(h=ring_height, d=ring_od, center=false);
        }

        // Inner void through entire part (pipe + rings)
        translate([0, 0, -ring_height - overlap])
            cylinder(h=length + 2*ring_height + 2*overlap, d=id, center=false);
    }
}

ht_pipe();