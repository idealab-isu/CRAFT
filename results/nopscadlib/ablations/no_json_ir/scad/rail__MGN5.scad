$fn = 64;

// Miniature linear guide rail: 100mm long, 5.0mm wide, 3.6mm tall
// One connected solid; no text.

module linear_guide_rail(L=100, W=5.0, H=3.6) {

    // Feature sizes (kept within envelope)
    fillet_r = 0.35;

    // Side raceway grooves (subtractive)
    groove_r = 0.55;
    groove_depth = 0.35;                 // how far the groove cuts into the side
    groove_z = H*0.62;                   // vertical placement of groove center

    // Mounting holes (subtractive)
    hole_r = 0.75;                       // ~1.5mm dia
    hole_head_r = 1.25;                  // shallow counterbore
    head_depth = 0.6;

    // End chamfers (subtractive)
    chamfer_len = 1.0;

    // Hole pattern along length
    hole_margin = 10;
    hole_pitch = 20;
    hole_count = floor((L - 2*hole_margin)/hole_pitch) + 1;

    // Build as a single connected solid using difference() on a filleted body
    difference() {
        // Main body with small edge fillets (Minkowski keeps it one solid)
        minkowski() {
            cube([L - 2*fillet_r, W - 2*fillet_r, H - 2*fillet_r], center=false);
            sphere(r=fillet_r);
        }

        // Side raceway grooves (two long cylinders cutting into the sides)
        // Left side groove
        translate([0, groove_depth, groove_z])
            rotate([0, 90, 0])
                cylinder(h=L, r=groove_r, center=false);

        // Right side groove
        translate([0, W - groove_depth, groove_z])
            rotate([0, 90, 0])
                cylinder(h=L, r=groove_r, center=false);

        // Mounting through-holes + shallow counterbore from top
        for (i = [0 : hole_count-1]) {
            x = hole_margin + i*hole_pitch;

            // Through hole (Z axis)
            translate([x, W/2, -0.2])
                cylinder(h=H + 0.4, r=hole_r, center=false);

            // Counterbore (top)
            translate([x, W/2, H - head_depth])
                cylinder(h=head_depth + 0.2, r=hole_head_r, center=false);
        }

        // End chamfers (remove wedges at both ends)
        // Start end
        translate([0, -0.2, -0.2])
            linear_extrude(height=H + 0.4)
                polygon(points=[
                    [0, 0],
                    [chamfer_len, 0],
                    [0, W + 0.4]
                ]);

        // Far end
        translate([L, -0.2, -0.2])
            mirror([1,0,0])
                linear_extrude(height=H + 0.4)
                    polygon(points=[
                        [0, 0],
                        [chamfer_len, 0],
                        [0, W + 0.4]
                    ]);
    }
}

linear_guide_rail();