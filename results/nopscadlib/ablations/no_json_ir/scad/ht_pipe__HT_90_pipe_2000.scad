$fn = 32;

// HT pipe oriented along X so orthographic views show the 2000 mm length clearly.
module ht_pipe(type="HT 90", length=2000) {
    if (type == "HT 90" && length == 2000) {

        // Nominal HT 90 dimensions (approx.)
        d_body      = 90;     // outer diameter
        wall        = 3.2;    // wall thickness
        d_inner     = d_body - 2*wall;

        // Socket / sleeve at both ends (outer step)
        fit_h       = 50;
        d_fit_outer = 100;    // socket outer diameter (approx.)
        d_fit_inner = d_inner;

        // Small overlaps to avoid coincident faces
        overlap_ax  = 0.5;
        overlap_rad = 0.2;

        // Helper: hollow tube along X (fast: single difference, no extra cutters)
        module tube_x(L, d_o, d_i) {
            rotate([0, 90, 0])
                difference() {
                    cylinder(h=L, d=d_o, center=false);
                    cylinder(h=L, d=d_i, center=false);
                }
        }

        // Build as one solid outer union, then subtract one continuous inner bore
        difference() {
            union() {
                // Main outer body
                rotate([0,90,0]) cylinder(h=length, d=d_body, center=false);

                // Left outer socket
                rotate([0,90,0]) cylinder(h=fit_h + overlap_ax, d=d_fit_outer, center=false);

                // Right outer socket
                translate([length - fit_h - overlap_ax, 0, 0])
                    rotate([0,90,0]) cylinder(h=fit_h + overlap_ax, d=d_fit_outer, center=false);
            }

            // Inner bore through entire length (slightly extended to avoid coplanar faces)
            translate([-overlap_ax, 0, 0])
                rotate([0,90,0]) cylinder(h=length + 2*overlap_ax, d=d_inner - overlap_rad, center=false);
        }
    }
}

ht_pipe("HT 90", 2000);