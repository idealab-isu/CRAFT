// Long slender rail with evenly spaced perpendicular tabs (flat plate)
// Target bounding box: 149.2 x 27.2 x 2.6 mm

// Overall bounding box
L = 149.2;   // length (X)
W = 27.2;    // overall width across tabs (Y)
T = 2.6;     // thickness (Z)

// Spine and tab geometry
spine_w = 6.0;   // spine width (Y)
tab_x   = 3.0;   // tab thickness along length (X)

// Tab layout
end_margin = 8.0;      // from each end to first/last tab center
tab_pitch  = 16.64375; // spacing between tab centers
tab_count  = 9;        // number of tabs

// Small overlap to guarantee watertight union
eps = 0.2;

// Derived checks/placements (formula-based)
first_tab_x = -L/2 + end_margin;
last_tab_x  = first_tab_x + (tab_count - 1) * tab_pitch;

// Base shapes
module spine_bar() {
    cube([L, spine_w, T], center=true);
}

module tab_at_x(xpos) {
    // Symmetric about spine centerline in Y; overlaps spine in X by eps
    translate([xpos, 0, 0])
        cube([tab_x + eps, W, T], center=true);
}

// Final model (single connected solid)
union() {
    spine_bar();

    for (i = [0 : tab_count - 1]) {
        tab_at_x(first_tab_x + i * tab_pitch);
    }
}