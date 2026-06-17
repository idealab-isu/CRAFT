// Symmetric cross-shaped hub (one connected solid)
// Target bounding box: 11.7 x 11.7 x 6.3 mm

$fn = 96;

// Bounding box (reference)
bbox_X = 11.7;
bbox_Y = 11.7;
bbox_Z = 6.3;

// Core
core_d = 6.0;
core_h = bbox_Z;

// Tabs (lugs)
tab_w_tangential = 3.0;          // width of each tab (tangential)
tab_h = bbox_Z;                  // centered about mid-height
tab_len_radial = (bbox_X - core_d) / 2;  // ensures overall X/Y = bbox_X/bbox_Y

// Small overlap to guarantee manifold union
overlap = 0.2;

module hub() {
    union() {
        // Central cylinder
        cylinder(d=core_d, h=core_h, center=true);

        // Four orthogonal tabs, centered at mid-height
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a])
                translate([core_d/2 + tab_len_radial/2 - overlap/2, 0, 0])
                    cube([tab_len_radial + overlap, tab_w_tangential, tab_h], center=true);
        }
    }
}

hub();