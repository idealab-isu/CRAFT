// HT 40 pipe, length 250 mm (single connected solid)
$fn = 160;

outer_diameter = 50;     // mm
wall_thickness = 3;      // mm
length = 250;            // mm

// End collar (small flare/ring) dimensions
collar_radial = 2.5;     // mm added to radius
collar_h = 5;            // mm height
overlap = 0.6;           // mm overlap to guarantee connectivity / avoid coplanar faces

inner_diameter = outer_diameter - 2*wall_thickness;

module pipe_shell(h, od, id) {
    difference() {
        cylinder(h=h, d=od, center=false);
        translate([0, 0, -overlap])
            cylinder(h=h + 2*overlap, d=id, center=false);
    }
}

module end_collar(od, id, collar_radial, collar_h) {
    difference() {
        cylinder(h=collar_h, d=od + 2*collar_radial, center=false);
        translate([0, 0, -overlap])
            cylinder(h=collar_h + 2*overlap, d=id, center=false);
    }
}

module ht_pipe() {
    union() {
        // Main pipe
        pipe_shell(length, outer_diameter, inner_diameter);

        // Bottom collar (connected by overlap)
        translate([0, 0, -(collar_h - overlap)])
            end_collar(outer_diameter, inner_diameter, collar_radial, collar_h);

        // Top collar (connected by overlap)
        translate([0, 0, length - overlap])
            end_collar(outer_diameter, inner_diameter, collar_radial, collar_h);
    }
}

ht_pipe();