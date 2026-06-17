// HT 125 pipe, length 150 mm (one connected solid, hollow)
// Pipe with a small outer collar (socket-like ring) at one end.

$fn = 200;

// Parameters (mm)
outer_diameter  = 125;
wall_thickness  = 3.2;
length          = 150;

// Collar (outer ring) at one end
collar_radial   = 4;   // added to radius
collar_height   = 4;   // axial height

// Robustness overlap (mm)
overlap = 0.6;

module ht_pipe() {
    inner_diameter = outer_diameter - 2 * wall_thickness;

    difference() {
        // OUTER SOLID: main pipe + collar, guaranteed connected by overlap
        union() {
            // Main outer cylinder
            cylinder(h=length, d=outer_diameter, center=false);

            // Collar at the bottom end (z = 0 .. collar_height)
            // Slightly overlaps into main cylinder to ensure manifold union
            translate([0, 0, -overlap])
                cylinder(h=collar_height + overlap, d=outer_diameter + 2*collar_radial, center=false);
        }

        // INNER VOID: through entire length (open ends), including collar region
        translate([0, 0, -overlap])
            cylinder(h=length + collar_height + 2*overlap, d=inner_diameter, center=false);
    }
}

ht_pipe();