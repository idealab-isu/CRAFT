$fn = 128;

// HT pipe parameters (approximate for HT 125)
pipe_length = 1500;          // mm
outer_diameter = 125;        // mm (nominal)
wall_thickness = 3.2;        // mm (typical for HT DN125; adjust if needed)

outer_radius = outer_diameter/2;
inner_radius = outer_radius - wall_thickness;

module ht_pipe(od, t, L) {
    difference() {
        cylinder(h=L, r=od/2, center=false);
        translate([0,0,-0.5])
            cylinder(h=L+1, r=od/2 - t, center=false);
    }
}

ht_pipe(outer_diameter, wall_thickness, pipe_length);