// PTFE sleeving / tubing (hollow cylinder) - single connected solid

module tubing(tubing_type="standard", length=100, forced_internal_diameter=undef, center=false) {

    // Dimensions by type
    outer_diameter =
        (tubing_type == "thin")  ? 8  :
        (tubing_type == "thick") ? 12 : 10;

    wall_thickness =
        (tubing_type == "thin")  ? 0.5 :
        (tubing_type == "thick") ? 1.5 : 1;

    // Derived inner diameter (clamped to avoid invalid/blank geometry)
    inner_from_wall = outer_diameter - 2*wall_thickness;
    internal_diameter_raw = (forced_internal_diameter == undef) ? inner_from_wall : forced_internal_diameter;

    // Ensure inner diameter is positive and smaller than outer diameter
    eps = 0.02;
    internal_diameter = min(max(internal_diameter_raw, eps), outer_diameter - eps);

    // Make a true hollow sleeve using difference (one connected solid)
    difference() {
        cylinder(d=outer_diameter, h=length, center=center, $fn=128);

        // Slightly longer inner cut to guarantee through-hole regardless of centering
        cylinder(d=internal_diameter, h=length + 2*eps, center=center, $fn=128);
    }
}

// Example usage
tubing(tubing_type="standard", length=150, center=true);