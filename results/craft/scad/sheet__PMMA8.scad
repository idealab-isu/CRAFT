// Sheet parameters (mm)
sheet_L = 100;                 // length
sheet_W = 100;                 // width
sheet_T = 25.4 * 5/16;         // thickness (~5/16" = 0.3125" = 7.9375 mm)

// Render quality
$fn = 64;

// Geometry: one connected solid plate, placed on Z=0 for clear thickness in side views
module sheet_plate(L, W, T) {
    color([0.85, 0.85, 0.8])
        translate([0, 0, T/2])
            cube([L, W, T], center=true);
}

// Final output
sheet_plate(sheet_L, sheet_W, sheet_T);