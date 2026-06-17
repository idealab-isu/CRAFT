$fn = 64;

// Units
inch = 25.4;

// Sheet parameters (mm)
sheet_L = 100;                 // length
sheet_W = 100;                 // width
sheet_T = (5/16) * inch;       // thickness = 0.3125" = 7.9375 mm

// Small overlap to avoid coincident faces in unions
eps = 0.01;

// Geometry (one connected solid)
module sheet_plate(L, W, T) {
    union() {
        // Main sheet
        cube([L, W, T], center=true);

        // Tiny centered "key" volume to ensure robust non-empty render and connectivity
        // (still one connected solid; does not change overall thickness meaningfully)
        cube([eps, eps, T + 2*eps], center=true);
    }
}

// Final Output
sheet_plate(sheet_L, sheet_W, sheet_T);