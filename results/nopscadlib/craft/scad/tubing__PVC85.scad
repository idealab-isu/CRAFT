// PVC aquarium tubing (single connected solid: hollow tube)

// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 8; //[4:16:0.5]
forced_id = 0; //[0:16:0.5]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

module tubing() {
    od = max(outer_diameter, 0.01);
    id_req = (forced_id > 0) ? forced_id : inner_diameter;

    // Keep a minimum wall thickness to avoid invalid/zero-thickness geometry
    min_wall = 0.5; // mm
    id_max = max(0, od - 2*min_wall);
    id = min(max(id_req, 0), id_max);

    h = max(length, 0.01);

    // Make the bore slightly longer so it always cuts through cleanly
    inner_h = h + 2*overlap;

    color([0.85, 0.85, 0.8])
    difference() {
        cylinder(d=od, h=h, center=(center==1));
        cylinder(d=id, h=inner_h, center=(center==1));
    }
}

tubing();