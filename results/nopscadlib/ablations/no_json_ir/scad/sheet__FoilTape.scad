// Aluminium foil tape SHEET (flat strip) - ONE connected solid
// Structural fix: model is now a standalone sheet-like foil tape, not a roll.
// All translate() values are formula-based; all parts overlap slightly to ensure a single solid.

$fn = 96;

// Parameters (mm)
sheet_len        = 220;   // overall length of the tape sheet
sheet_w          = 50;    // width of the tape sheet
tape_thickness   = 0.35;  // thin foil tape thickness (simplified)
corner_radius    = 2.0;   // rounded corners
peel_len         = 35;    // length of slightly lifted/peeled end
peel_lift        = 3.0;   // lift height at the very end
overlap          = 1.2;   // 1-2mm overlap for guaranteed manifold union

// 2D rounded rectangle
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    minkowski() {
        square([L - 2*R2, W - 2*R2], center=true);
        circle(r=R2);
    }
}

// Main flat sheet
module foil_sheet_main() {
    linear_extrude(height=tape_thickness, center=true)
        rounded_rect_2d(sheet_len, sheet_w, corner_radius);
}

// Slightly peeled/lifted end (still connected to the sheet via overlap)
module foil_sheet_peeled_end() {
    // Place peeled section at +X end of the sheet
    // Main sheet spans X: [-sheet_len/2, +sheet_len/2]
    // Peeled section spans X: [sheet_len/2 - peel_len, sheet_len/2]
    x_root = sheet_len/2 - peel_len + overlap/2; // overlap into main sheet
    x_tip  = sheet_len/2 - 0.5;                  // near the very end

    // Thin "plates" hulled to form a gentle wedge
    plate_t = 0.25;

    hull() {
        // Root plate: sits on top surface of the main sheet, overlapping into it
        translate([x_root, 0, tape_thickness/2 - plate_t/2])
            cube([peel_len + overlap, sheet_w, plate_t], center=true);

        // Tip plate: lifted in +Z to suggest peeling
        translate([x_tip, 0, tape_thickness/2 + peel_lift])
            cube([1.0, sheet_w, plate_t], center=true);
    }
}

// Subtle edge thickening strip (suggests tape body; kept simple and connected)
module foil_edge_reinforcement() {
    // A very shallow rib along one long edge, embedded into the sheet
    rib_w = 3.0;
    rib_t = 0.25;

    // Position rib along +Y edge, overlapping into the sheet by overlap
    y_center = (sheet_w/2 - rib_w/2) - overlap/2;

    translate([0, y_center, 0])
        cube([sheet_len, rib_w, tape_thickness + rib_t], center=true);
}

// Assemble: one connected solid
module aluminium_foil_tape_sheet() {
    union() {
        foil_sheet_main();
        foil_sheet_peeled_end();       // overlaps into main sheet
        foil_edge_reinforcement();     // overlaps into main sheet
    }
}

aluminium_foil_tape_sheet();