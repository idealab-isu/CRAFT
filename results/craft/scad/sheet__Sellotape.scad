// Sellotape tape SHEET (one connected solid)
// Replaces roll/ring with a thin rectangular sheet to match: "A sheet: Sellotape tape"

tape_length    = 100;   //[50:200:1]   // sheet length
tape_width     = 19;    //[10:38:1]    // sheet width
tape_thickness = 0.05;  //[0.02:0.2:0.01] // sheet thickness (visual)

$fn = 80;

// Ensure printable/visible minimums while keeping proportions
L = max(50, tape_length);
W = max(10, tape_width);
T = max(0.2, tape_thickness);   // give the "sheet" real thickness for a solid model

// Small overlap to guarantee single-solid connectivity between layers
overlap = 1.0;

// Simple "Sellotape sheet" look: a thin tape layer + a slightly thicker backing edge,
// fused together (single union) with overlap.
module sellotape_sheet(){
    union() {
        // Main tape sheet
        color([0.88, 0.88, 0.82])
        cube([L, W, T], center=true);

        // Slightly thicker "edge/backing" strip along one long side (still one solid)
        // Positioned by formula so it touches/overlaps the main sheet.
        backing_w = max(2, W*0.18);
        backing_t = T + 0.6; // subtle thickness cue
        translate([0, (W/2 - backing_w/2) - overlap/2, 0])
            color([0.92, 0.90, 0.85])
            cube([L, backing_w, backing_t], center=true);
    }
}

sellotape_sheet();