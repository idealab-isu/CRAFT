$fn = 360;

// --- Required spec ---
teeth   = 80;
pitch_d = 50.42;                 // mm (pitch diameter)

// --- Derived from spec ---
pitch   = PI * pitch_d / teeth;  // circular pitch along pitch circle
r_pitch = pitch_d / 2;

// --- Pulley dimensions (kept from original unless needed) ---
pulley_width = 12;               // mm
bore_d       = 5;                // mm
hub_d        = 22;               // mm
hub_height   = 16;               // mm

// --- Tooth geometry (simple timing-tooth approximation) ---
// Make teeth clearly resolved and ensure pitch diameter is honored by placing tooth centerline at r_pitch.
tooth_height = 1.6;              // mm radial height above root
tooth_top_w  = 0.35 * pitch;     // tangential width at tip
tooth_base_w = 0.75 * pitch;     // tangential width at root

// Overlap to guarantee watertight union between teeth and root cylinder
overlap = 0.35;                  // mm

// Root and tip radii
r_root = r_pitch - tooth_height;
r_tip  = r_pitch + tooth_height;

// Tooth 2D profile in XY plane:
// X = tangential, Y = radial outward.
// The profile is centered on X and spans from -tooth_height (into root) to +tooth_height (outward),
// so the tooth centerline lies exactly on the pitch circle when placed at r_pitch.
module tooth2d() {
    polygon(points=[
        [-tooth_base_w/2, -tooth_height - overlap],
        [ tooth_base_w/2, -tooth_height - overlap],
        [ tooth_top_w/2,   tooth_height],
        [-tooth_top_w/2,   tooth_height]
    ]);
}

module pulley_body() {
    union() {
        // Root cylinder (tooth valleys)
        cylinder(h=pulley_width, r=r_root, center=true);

        // Teeth: place tooth centerline at pitch radius so pitch diameter matches pitch_d
        for (i = [0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                translate([r_pitch, 0, 0])
                    linear_extrude(height=pulley_width, center=true, convexity=10)
                        tooth2d();
        }
    }
}

module hub() {
    cylinder(h=hub_height, r=hub_d/2, center=true);
}

difference() {
    union() {
        pulley_body();
        hub();
    }

    // Bore through entire part
    cylinder(h=max(pulley_width, hub_height) + 2, r=bore_d/2, center=true);

    // End relief/chamfer-ish cuts (subtractive only)
    chamfer_h = 1.2;
    translate([0,0, pulley_width/2 - chamfer_h])
        cylinder(h=chamfer_h + 0.02, r1=r_tip, r2=r_root, center=false);
    translate([0,0,-pulley_width/2])
        cylinder(h=chamfer_h + 0.02, r1=r_root, r2=r_tip, center=false);
}