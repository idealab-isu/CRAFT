// Symmetric cross-shaped hub (one connected solid)
// Target bounding box: 11.7 x 11.7 x 6.3 mm

$fn = 96;

// Bounding box (reference)
bbox_X = 11.68;
bbox_Y = 11.68;
bbox_Z = 6.35;

// Core (circular hub)
core_d = 6.0;
core_h = bbox_Z;

// Tabs (lugs)
tab_len_radial = (bbox_X - core_d) / 2;   // ensures overall X/Y matches bbox
tab_w_tangential = 3.2;
tab_h = 3.2;

// Small overlap to guarantee watertight union
overlap = 0.2;

// Tabs centered around cylinder mid-height (as in views)
tab_z = 0;

module core() {
    cylinder(d=core_d, h=core_h, center=true);
}

module tab_at_angle(a) {
    // Place tab so its inner face overlaps into the core by "overlap"
    // Inner edge radius = core_d/2 - overlap
    // Tab center radius = (core_d/2 - overlap) + tab_len_radial/2
    rotate([0, 0, a])
        translate([core_d/2 + tab_len_radial/2 - overlap, 0, tab_z])
            cube([tab_len_radial, tab_w_tangential, tab_h], center=true);
}

union() {
    core();
    tab_at_angle(0);
    tab_at_angle(90);
    tab_at_angle(180);
    tab_at_angle(270);
}