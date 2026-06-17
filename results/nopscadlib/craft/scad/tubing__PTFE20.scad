// PTFE sleeving (tubing) - robust, non-empty geometry

length = 15; //[8:30:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter_nominal = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
center = true; //[0:1:1]
overlap = 0.8; //[0.5:2:0.1]

$fn = 96;

module tubing() {
    od = max(outer_diameter, 0.01);
    id_req = (forced_id > 0) ? forced_id : inner_diameter_nominal;

    // Keep a guaranteed wall thickness so the tube never collapses to empty
    min_wall = 0.25;                 // mm
    id = min(max(id_req, 0), max(0, od - 2*min_wall));

    h = max(length, 0.01);

    // Ensure the inner cutter fully passes through regardless of centering
    z_shift = center ? 0 : -overlap;

    color([0.85, 0.85, 0.8])  // PTFE color
    difference() {
        cylinder(h=h, r=od/2, center=center);
        translate([0, 0, z_shift])
            cylinder(h=h + 2*overlap, r=id/2, center=center);
    }
}

tubing();