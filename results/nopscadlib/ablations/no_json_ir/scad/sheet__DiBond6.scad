// Sheet DiBond (aluminum composite panel): aluminum skin + polyethylene core + aluminum skin
// One connected solid with visually distinguishable layers (via slight in-plane inset + overlap)

module dibond_sheet(width=200, height=100, thickness=3, skin=0.3) {
    eps = 0.02;                       // tiny overlap to guarantee watertight union
    skin_t = max(skin, 0.05);
    core_t = max(thickness - 2*skin_t, 0.01);

    // Small inset so the core is visible from the sides (material distinction)
    inset = min(0.6, width/20, height/20);

    union() {
        // Bottom aluminum skin (full size)
        translate([0, 0, 0])
            cube([width, height, skin_t + eps], center=false);

        // Polyethylene core (slightly inset in X/Y so it shows on edges)
        translate([inset, inset, skin_t - eps])
            cube([width - 2*inset, height - 2*inset, core_t + 2*eps], center=false);

        // Top aluminum skin (full size)
        translate([0, 0, skin_t + core_t - eps])
            cube([width, height, skin_t + eps], center=false);
    }
}

// Main model
dibond_sheet();