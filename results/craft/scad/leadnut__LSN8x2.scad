// Leadscrew nut housing: 8.0mm x 10.2mm x 15.0mm block with through-bore and mounting holes
// Overall dimensions are preserved exactly by only subtracting features.

$fn = 64;

width_mm  = 8.0;   //[4.0:16.0:0.1]  // X
depth_mm  = 10.2;  //[5.1:20.4:0.1]  // Y
height_mm = 15.0;  //[7.5:30.0:0.1]  // Z

// Feature parameters (typical small leadscrew nut housing)
bore_d_mm        = 4.2;   // through-hole for leadscrew
mount_hole_d_mm  = 2.2;   // two mounting through-holes
mount_spacing_mm = 6.0;   // center-to-center along Y
edge_margin_mm   = 1.2;   // keep holes away from edges

eps = 0.02;

module leadscrew_nut_housing() {
    difference() {
        // Main block (exact overall size)
        cube([width_mm, depth_mm, height_mm], center=true);

        // Central through-bore along Z
        cylinder(d=bore_d_mm, h=height_mm + 2*eps, center=true);

        // Two mounting through-holes along Z, placed symmetrically along Y
        // Ensure spacing fits within depth with margin
        spacing = min(mount_spacing_mm, max(0, depth_mm - 2*edge_margin_mm));
        for (y = [-spacing/2, spacing/2]) {
            translate([0, y, 0])
                cylinder(d=mount_hole_d_mm, h=height_mm + 2*eps, center=true);
        }

        // Small side relief slot to suggest nut capture (does not change outer size)
        // Slot opens to +X face and intersects the central bore.
        slot_w = min(2.0, width_mm - 2*edge_margin_mm);
        slot_h = min(6.0, height_mm - 2*edge_margin_mm);
        translate([width_mm/2 - slot_w/2 + eps, 0, 0])
            cube([slot_w + 2*eps, bore_d_mm + 1.0, slot_h], center=true);
    }
}

leadscrew_nut_housing();