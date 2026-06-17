$fn = 64;

// DiBond sheet (aluminum skins + composite core) as ONE connected solid
sheet_length    = 300;
sheet_width     = 200;
sheet_thickness = 3;

// Typical DiBond construction: ~0.3 mm aluminum skins each side
skin_t = 0.3;
eps    = 0.05; // small overlap to guarantee manifold connectivity

module dibond_sheet(L, W, T, skin, overlap=0.05) {
    core = T - 2*skin;
    assert(core > 0, "skin thickness too large for total thickness");

    // Center the whole sheet at origin so it is always visible and well-framed
    translate([0, 0, -T/2])
    union() {
        // Bottom aluminum skin (slightly overlaps into core)
        color([0.80, 0.80, 0.83])
            translate([-L/2, -W/2, 0])
                cube([L, W, skin + overlap], center=false);

        // Core (overlaps into both skins)
        color([0.15, 0.15, 0.15])
            translate([-L/2, -W/2, skin - overlap])
                cube([L, W, core + 2*overlap], center=false);

        // Top aluminum skin (slightly overlaps into core)
        color([0.80, 0.80, 0.83])
            translate([-L/2, -W/2, skin + core - overlap])
                cube([L, W, skin + overlap], center=false);
    }
}

dibond_sheet(sheet_length, sheet_width, sheet_thickness, skin_t, eps);