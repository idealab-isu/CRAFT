// PTFE sleeving (tubing) - single connected solid

// Parameters
length = 15; //[7.5:30:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
center = true; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

// Smoothness
$fa = 3;
$fs = 0.15;
$fn = 0;

module tubing() {
    wall_min = 0.2;

    od = max(outer_diameter, 2*wall_min);
    id_in = (forced_id > 0) ? forced_id : inner_diameter;

    // Clamp ID so the tube always has a positive wall thickness
    id_safe = min(max(id_in, 0), od - 2*wall_min);

    // Ensure the inner cutter fully passes through regardless of centering
    h_outer = length;
    h_inner = length + 2*overlap;

    z_shift = center ? 0 : -overlap; // formulas only; guarantees through-cut when center=false

    color([0.85, 0.85, 0.8])
    difference() {
        cylinder(h=h_outer, r=od/2, center=center);
        translate([0, 0, z_shift])
            cylinder(h=h_inner, r=id_safe/2, center=center);
    }
}

tubing();