// HT 50 pipe 250 mm

outer_diameter = 50;      // mm
wall_thickness = 1.8;     // mm
length = 250;             // mm
eps = 0.2;                // overlap to avoid coplanar faces
$fn = 128;

inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe_segment() {
    difference() {
        // Centered outer solid for reliable viewing/orientation
        cylinder(h=length, d=outer_diameter, center=true);

        // Inner void: slightly longer so it fully subtracts through both ends
        cylinder(h=length + 2*eps, d=inner_diameter, center=true);
    }
}

ht_pipe_segment();