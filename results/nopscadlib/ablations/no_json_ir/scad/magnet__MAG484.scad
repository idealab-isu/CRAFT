// Single connected solid: faceted cylindrical magnet with optional through-bore
module magnet_vitamin(magnet_type="cylinder", diameter=10, height=5, bore_diameter=0) {

    // Robust, non-degenerate dimensions
    d  = max(0.1, diameter);
    h  = max(0.1, height);
    bd = max(0, bore_diameter);

    // Keep bore smaller than outer diameter to avoid empty/invalid geometry
    bd_safe = (bd > 0) ? min(bd, d - 0.2) : 0;

    // Faceted look like reference
    fn_cyl = 12;

    difference() {
        // Magnet body
        if (magnet_type == "block") {
            cube([d, d, h], center=true);
        } else {
            cylinder(d=d, h=h, center=true, $fn=fn_cyl);
        }

        // Optional through-bore (cuts fully through with small margin)
        if (bd_safe > 0) {
            cylinder(d=bd_safe, h=h + 0.5, center=true, $fn=fn_cyl);
        }
    }
}

// Example usage
magnet_vitamin(magnet_type="cylinder", diameter=10, height=5, bore_diameter=2);