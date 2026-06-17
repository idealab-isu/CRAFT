// Toggle switch (single connected solid)
// Target: 0.8mm body diameter, 4.7mm overall height
// Model is centered on Z for consistent orthographic views.

$fn = 96;

// ---- Target dimensions ----
body_diameter_mm   = 0.8;   // main bushing/body diameter
overall_height_mm  = 4.7;   // total height from bottom to top

// ---- Shape controls (kept small, derived/validated) ----
overlap_mm = 0.05;          // intentional overlap to guarantee manifold union

// Base flange (nut/washer look)
flange_diameter_mm  = 1.25;
flange_thickness_mm = 0.35;

// Hex nut section (gives "toggle switch" recognizable body)
nut_flat_to_flat_mm = 1.15; // across flats
nut_thickness_mm    = 0.55;

// Cylindrical bushing/body above nut
bushing_height_mm   = 0.85;

// Lever (actuator)
lever_diameter_mm   = 0.30;
tip_radius_mm       = 0.20;

// Small collar at lever base (visual cue)
collar_diameter_mm  = 0.55;
collar_height_mm    = 0.18;

// ---- Derived heights to hit overall_height_mm exactly ----
fixed_stack_mm = flange_thickness_mm + nut_thickness_mm + bushing_height_mm + collar_height_mm;
lever_height_mm = max(0.6, overall_height_mm - fixed_stack_mm - tip_radius_mm); // tip adds ~tip_radius above lever
// Recompute bushing if lever got clamped (keeps total exact)
bushing_height_adj_mm = max(0.2, overall_height_mm - (flange_thickness_mm + nut_thickness_mm + collar_height_mm + lever_height_mm + tip_radius_mm));

// ---- Helpers ----
module hex_prism(flat_to_flat, h, center=true) {
    // For a regular hexagon: across flats = 2 * apothem = sqrt(3) * R
    // => circumradius R = flat_to_flat / sqrt(3)
    cylinder(h=h, r=flat_to_flat / sqrt(3), $fn=6, center=center);
}

module toggle_switch() {
    // Build from bottom to top, then center the whole assembly on Z.
    total_h = overall_height_mm;
    z0 = -total_h/2; // bottom plane

    union() {
        // Base flange (washer)
        translate([0, 0, z0 + flange_thickness_mm/2])
            cylinder(d=flange_diameter_mm, h=flange_thickness_mm, center=true);

        // Hex nut (overlaps into flange)
        translate([0, 0, z0 + flange_thickness_mm - overlap_mm + nut_thickness_mm/2])
            hex_prism(nut_flat_to_flat_mm, nut_thickness_mm, center=true);

        // Cylindrical bushing/body (0.8mm diameter) (overlaps into nut)
        translate([0, 0, z0 + flange_thickness_mm + nut_thickness_mm - overlap_mm + bushing_height_adj_mm/2])
            cylinder(d=body_diameter_mm, h=bushing_height_adj_mm, center=true);

        // Small collar at lever base (overlaps into bushing)
        translate([0, 0, z0 + flange_thickness_mm + nut_thickness_mm + bushing_height_adj_mm - overlap_mm + collar_height_mm/2])
            cylinder(d=collar_diameter_mm, h=collar_height_mm, center=true);

        // Lever (overlaps into collar)
        translate([0, 0, z0 + flange_thickness_mm + nut_thickness_mm + bushing_height_adj_mm + collar_height_mm - overlap_mm + lever_height_mm/2])
            cylinder(d=lever_diameter_mm, h=lever_height_mm, center=true);

        // Rounded tip (overlaps into lever)
        translate([0, 0, z0 + flange_thickness_mm + nut_thickness_mm + bushing_height_adj_mm + collar_height_mm + lever_height_mm - overlap_mm])
            sphere(r=tip_radius_mm);
    }
}

toggle_switch();