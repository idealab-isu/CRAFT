// Toggle switch (miniature) - ONE connected solid
// Target: 0.8mm body diameter, 4.7mm overall height
// Connectivity fix: ensure paddle/caps are physically attached to the main body
// by adding a small "bridge" block that overlaps both the body and the paddle.

$fn = 32;

// Targets (do not change)
body_diameter_mm   = 0.8;  //[0.4:1.6:0.01]
overall_height_mm  = 4.7;  //[2.35:9.4:0.01]

// Connectivity / shaping
connect_overlap_mm = 0.08; //[0.02:0.2:0.01]

// Derived
body_r = body_diameter_mm/2;

// Height allocation (sum = overall_height_mm)
base_h   = overall_height_mm * 0.58;                 // main body height
collar_h = max(0.10, overall_height_mm * 0.10);      // small collar
lever_h  = overall_height_mm - base_h - collar_h;    // remaining for lever

// Radii (keep within 0.8mm max diameter envelope)
collar_r = body_r * 0.98;
lever_r  = body_r * 0.28;

// Toggle-specific silhouette: a "paddle" lever (not just a pin)
paddle_w = body_diameter_mm * 0.95;  // X
paddle_t = body_diameter_mm * 0.22;  // Y (thin)
paddle_h = lever_h * 0.55;           // Z portion of lever that is paddle-like

// Small rounded-ish tip at top of lever (kept simple)
tip_r = min(body_r * 0.30, lever_r * 1.15);
tip_h = max(0.12, lever_h * 0.18);

module toggle() {
    union() {
        // Main cylindrical body
        translate([0,0, base_h/2])
            cylinder(r=body_r, h=base_h, center=true);

        // Subtle housing bulge (simplified: plain box instead of rounded hull)
        housing_h = min(base_h * 0.55, body_diameter_mm * 0.75);
        housing_w = body_diameter_mm * 0.98; // X
        housing_d = body_diameter_mm * 0.70; // Y
        translate([0,0, base_h*0.55])
            cube([housing_w, housing_d, housing_h], center=true);

        // Collar under lever (connected)
        translate([0,0, base_h + collar_h/2 - connect_overlap_mm])
            cylinder(r=collar_r, h=collar_h, center=true);

        // Lever stem (connected)
        stem_h = max(0.10, lever_h - paddle_h - tip_h);
        translate([0,0, base_h + collar_h + stem_h/2 - connect_overlap_mm])
            cylinder(r=lever_r, h=stem_h, center=true);

        // Paddle lever section (connected), slight forward tilt
        paddle_z0 = base_h + collar_h + stem_h - connect_overlap_mm;
        translate([0,0, paddle_z0 + paddle_h/2])
            rotate([18,0,0])
                cube([paddle_w, paddle_t, paddle_h], center=true);

        // --- Connectivity bridge (FIX) ---
        // The rotated paddle can end up only touching via the thin stem.
        // Add a small block that overlaps the body/collar region and the paddle,
        // guaranteeing a solid connection (1-2mm overlap requirement).
        //
        // Place it centered at the paddle base height, and make it thick enough in Y
        // to intersect the cylinder even with the 18° tilt.
        bridge_h = max(1.2, paddle_h * 0.55);                 // >= ~1.2mm overlap in Z
        bridge_w = max(paddle_w * 0.70, body_diameter_mm);    // spans across the body
        bridge_t = max(body_diameter_mm * 0.85, paddle_t*3);  // reaches into cylinder in Y

        // Center the bridge so its bottom overlaps the collar/stem region
        // and its top overlaps the paddle.
        bridge_zc = paddle_z0 + bridge_h/2 - 0.6; // ~0.6mm downward bias for overlap into collar/stem
        translate([0,0, bridge_zc])
            cube([bridge_w, bridge_t, bridge_h], center=true);

        // Tip/knob (connected)
        tip_z0 = base_h + collar_h + stem_h + paddle_h - connect_overlap_mm;
        translate([0,0, tip_z0 + tip_h/2])
            cylinder(r=tip_r, h=tip_h, center=true);
    }
}

toggle();