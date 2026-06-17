// HT 32 pipe 150 mm (connected, visible, hollow)
$fn = 180;

// Dimensions (mm)
outer_diameter  = 36.0;
wall_thickness  = 1.8;
length          = 150.0;

// End collar (simple fitting ring)
collar_extra_d  = 4.0;   // collar OD increase over pipe OD
collar_h        = 5.0;   // collar axial height
overlap         = 0.6;   // overlap to guarantee manifold union/difference

inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe() {
    difference() {
        // Outer solid (pipe + two collars) as ONE connected body
        union() {
            // Main outer cylinder
            cylinder(h=length, d=outer_diameter, center=false);

            // Bottom collar (overlaps into pipe)
            translate([0, 0, -(collar_h - overlap)])
                cylinder(h=collar_h, d=outer_diameter + collar_extra_d, center=false);

            // Top collar (overlaps into pipe)
            translate([0, 0, length - overlap])
                cylinder(h=collar_h, d=outer_diameter + collar_extra_d, center=false);
        }

        // Inner bore (extended through collars to keep them as rings)
        translate([0, 0, -(collar_h + 2*overlap)])
            cylinder(h=length + 2*collar_h + 4*overlap, d=inner_diameter, center=false);
    }
}

ht_pipe();