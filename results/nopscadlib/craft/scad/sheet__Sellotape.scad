// Sellotape tape SHEET (single connected solid)
// Simplified: a thin rectangular sheet with a small folded/peeled corner
// to make it recognizable as tape (not a roll).

$fn = 64;

// Parameters
sheet_length    = 120;   // overall tape piece length
sheet_width     = 19;    // tape width
sheet_thickness = 0.08;  // tape thickness (thin)
corner_fold_len = 18;    // length of peeled corner
corner_fold_w   = 10;    // width of peeled corner area
fold_lift       = 2.0;   // how much the corner lifts up
overlap         = 1.2;   // 1-2mm overlap for solid connections

module tape_sheet() {
    union() {
        // Main flat sheet (centered)
        cube([sheet_length, sheet_width, sheet_thickness], center=true);

        // Peeled/folded corner wedge (still one connected solid)
        // Attached at the +X end, +Y edge.
        // Use hull between two thin "tabs" to create a simple lifted corner.
        hull() {
            // Base tab on the sheet surface (overlaps into main sheet)
            translate([
                sheet_length/2 - corner_fold_len/2 - overlap/2,
                sheet_width/2 - corner_fold_w/2 - overlap/2,
                0
            ])
            cube([corner_fold_len + overlap, corner_fold_w + overlap, sheet_thickness], center=true);

            // Lifted tab (slightly smaller, raised in Z and shifted outward)
            translate([
                sheet_length/2 - corner_fold_len/2 + 2,
                sheet_width/2 - corner_fold_w/2 + 1,
                fold_lift
            ])
            cube([corner_fold_len*0.85, corner_fold_w*0.85, sheet_thickness], center=true);
        }

        // Subtle rounded leading edge strip (tiny thickening) to read as tape edge
        // Overlaps into main sheet so it's one solid.
        translate([0, -sheet_width/2 + 0.6, 0])
            cube([sheet_length, 1.2 + overlap, sheet_thickness + 0.02], center=true);
    }
}

// Final output
tape_sheet();