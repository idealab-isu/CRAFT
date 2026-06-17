// Heatshrink sleeving (hollow cylindrical tube) - single connected solid

// Parameters
length = 15; //[8:30:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter_original = 2; //[1:4:0.1]
forced_id = 0; //[0:4:0.1]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
path_enabled = 0; //[0:1:1]
path_length = 15; //[8:60:1]

// Derived
id_effective = (forced_id > 0 ? forced_id : inner_diameter_original);
od_effective = outer_diameter;
tube_h = (path_enabled > 0 ? path_length : length);

// Safety/robustness
eps = 0.02;
$fn = 96;

module heatshrink_tube() {
    // Ensure valid wall thickness
    id_safe = min(id_effective, od_effective - 2*eps);
    od_safe = max(od_effective, id_safe + 2*eps);

    difference() {
        cylinder(h=tube_h, r=od_safe/2, center=true);
        cylinder(h=tube_h + 2*overlap, r=id_safe/2, center=true);
    }
}

// Assembly (one connected solid: just the tube)
translate([0, 0, (center > 0 ? 0 : tube_h/2)])
    heatshrink_tube();