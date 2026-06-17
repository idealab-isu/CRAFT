$fn = 96;

// A sheet: Aluminium foil tape (single connected solid)
// Replaces roll/spool with a thin rectangular sheet/strip of foil tape.

//////////////////////
// User parameters
//////////////////////
tape_width      = 50;    // mm (across the tape)
tape_length     = 200;   // mm (along the tape)
tape_thickness  = 0.08;  // mm (foil tape thickness, visual)
edge_chamfer    = 0.6;   // mm (softened edges, simplified)
overlap         = 1.2;   // mm (intentional overlap to ensure watertight union)

//////////////////////
// Helpers
//////////////////////
module rounded_sheet(L, W, T, r) {
    // Simple rounded-rectangle prism using hull of corner cylinders.
    // Ensures a clean sheet silhouette without fine details.
    rr = min(r, W/2 - 0.01, L/2 - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - rr), sy*(W/2 - rr), 0])
                cylinder(r=rr, h=T, center=true);
        }
    }
}

module foil_tape_sheet() {
    // Main sheet body
    rounded_sheet(tape_length, tape_width, tape_thickness, edge_chamfer);

    // Slightly thicker "folded/raised" leading edge to read as foil tape sheet
    // Connected by overlap (no floating parts).
    lip_len = max(8, tape_length * 0.06);
    lip_thk = tape_thickness + 0.25; // subtle raised edge
    translate([tape_length/2 - lip_len/2 + overlap/2, 0, 0])
        rounded_sheet(lip_len + overlap, tape_width, lip_thk, edge_chamfer*0.8);

    // Subtle backing/adhesive hint as a shallow band on the underside (still one solid)
    // Implemented as a very thin rib that overlaps into the main sheet.
    band_len = tape_length * 0.35;
    band_w   = tape_width * 0.55;
    band_thk = tape_thickness + 0.12;
    translate([-tape_length/2 + band_len/2 - overlap/2, 0, 0])
        rounded_sheet(band_len + overlap, band_w, band_thk, edge_chamfer*0.6);
}

//////////////////////
// Render
//////////////////////
color([0.82, 0.82, 0.80])
union() {
    foil_tape_sheet();
}