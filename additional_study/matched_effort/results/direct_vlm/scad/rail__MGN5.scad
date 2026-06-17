$fn = 96;

// Miniature linear guide rail (mm)
rail_w = 5.0;
rail_h = 3.6;
rail_l = 100.0;

// Profile parameters (kept within overall envelope)
base_h   = 2.4;                 // base thickness
top_h    = rail_h - base_h;     // remaining height for top features

// Side grooves (visual "track" features)
groove_w = 0.9;
groove_d = 0.55;

// Central raised ridge (rail crown)
ridge_w  = 2.2;
ridge_h  = top_h;

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

module rail_solid() {
    // Build as a true 3D solid by extruding a 2D cross-section along length (Y).
    // This avoids accidental "sheet/edge" geometry and guarantees a connected manifold.
    linear_extrude(height=rail_l, center=false, convexity=10)
        difference() {
            // Outer envelope: exact 5.0mm (X) by 3.6mm (Z)
            square([rail_w, rail_h], center=false);

            // Two side grooves cut into the top surface
            for (sx = [0, 1]) {
                translate([
                    (sx == 0) ? 0 : (rail_w - groove_w),
                    rail_h - groove_d
                ])
                    square([groove_w, groove_d + eps], center=false);
            }

            // Shallow central relief channel (kept shallower than ridge height)
            relief_w = 1.0;
            relief_d = 0.25;
            translate([rail_w/2 - relief_w/2, rail_h - relief_d])
                square([relief_w, relief_d + eps], center=false);

            // Carve the "outside" of the ridge so the remaining material forms a raised crown.
            // Ridge sits on top of base_h and rises by ridge_h, staying within rail_h.
            translate([0, base_h])
                difference() {
                    // Only affect the upper region
                    square([rail_w, ridge_h + eps], center=false);

                    // Keep the ridge polygon; remove everything else in this upper region
                    translate([rail_w/2, 0])
                        polygon(points=[
                            [-ridge_w/2, 0],
                            [ ridge_w/2, 0],
                            [ ridge_w*0.35, ridge_h],
                            [-ridge_w*0.35, ridge_h]
                        ]);
                }
        }
}

// Orient length along X for clearer orthographic verification (100mm long)
rotate([0, -90, 0])
    rail_solid();