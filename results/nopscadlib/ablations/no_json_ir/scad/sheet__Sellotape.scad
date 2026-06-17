$fn = 128;

// A sheet: Sellotape tape (flat strip)
// Simple, recognizable: a thin rectangular tape sheet with a small folded/peeled corner.
// Single connected solid, with slight overlaps for watertight union.

tape_len   = 160;   // length of sheet (mm)
tape_w     = 50;    // width of sheet (mm)
tape_th    = 0.25;  // thickness of tape sheet (mm) - thin but printable-ish
overlap    = 1.0;   // overlap to guarantee solid connection (mm)

// Peeled corner (folded flap) parameters
flap_len   = 30;    // length of peeled corner along tape length (mm)
flap_w     = 22;    // width of peeled corner along tape width (mm)
flap_th    = tape_th;
flap_angle = 25;    // degrees lifted

module sellotape_sheet() {
    union() {
        // Main flat sheet (centered)
        cube([tape_len, tape_w, tape_th], center=true);

        // Peeled/folded corner flap: attached at one corner with overlap
        // Place flap so its inner corner overlaps the main sheet corner by 'overlap'
        // Main sheet extents: x = ±tape_len/2, y = ±tape_w/2, z = ±tape_th/2
        translate([
            tape_len/2 - flap_len/2 + overlap/2,
            tape_w/2 - flap_w/2 + overlap/2,
            tape_th/2 - flap_th/2 + overlap/2
        ])
        rotate([0, -flap_angle, 0])  // lift the corner upward
        cube([flap_len, flap_w, flap_th], center=true);
    }
}

sellotape_sheet();