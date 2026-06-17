$fn = 96;

// DiBond sheet dimensions (mm)
sheet_length    = 300;
sheet_width     = 200;
sheet_thickness = 3;

// DiBond construction: aluminum skins + polyethylene core
skin_thickness = 0.3;  // typical thin Al skin
corner_radius  = 2;

// Robust overlap to guarantee a single connected manifold after CGAL
eps = 0.05;

module rounded_plate(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    // Use minkowski for reliable rounded corners (avoids offset edge cases)
    linear_extrude(height=t, center=true, convexity=10)
        minkowski() {
            square([l - 2*r2, w - 2*r2], center=true);
            circle(r=r2);
        }
}

module dibond_sheet(l, w, t, r, skin_t){
    skin_t2 = min(skin_t, t/2 - eps);          // keep valid even if user sets too thick
    core_t  = max(t - 2*skin_t2, eps);         // ensure non-zero core

    union() {
        // Core (slightly thickened to overlap skins)
        color([0.10, 0.10, 0.10])
            rounded_plate(l, w, core_t + 2*eps, r);

        // Top aluminum skin (position computed from thicknesses; overlaps core by eps)
        color([0.80, 0.80, 0.83])
            translate([0, 0, core_t/2 + skin_t2/2 - eps])
                rounded_plate(l, w, skin_t2 + 2*eps, r);

        // Bottom aluminum skin (position computed from thicknesses; overlaps core by eps)
        color([0.80, 0.80, 0.83])
            translate([0, 0, -(core_t/2 + skin_t2/2 - eps)])
                rounded_plate(l, w, skin_t2 + 2*eps, r);
    }
}

dibond_sheet(sheet_length, sheet_width, sheet_thickness, corner_radius, skin_thickness);