// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Single connected solid, no extra hubs/flanges/set-screws.

$fn = 220;

// --- Required specs ---
tooth_count = 20;
pitch_diameter_mm = 12.22;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Basic pulley dimensions ---
pulley_width_mm = 10;
bore_diameter_mm = 5;

// --- Timing-tooth style (rounded GT/HTD-like approximation) ---
tooth_radial_height_mm = 1.25;     // tooth height above root cylinder
tooth_root_clearance_mm = 0.55;    // root cylinder sits inside pitch radius
tooth_overlap_mm = 0.35;           // overlap into root cylinder for watertight union

// Tangential tooth thickness at pitch circle (controls tooth count appearance)
tooth_pitch = PI * pitch_diameter_mm / tooth_count;
tooth_pitch_thickness_mm = tooth_pitch * 0.52;  // ~50% of pitch gives clear 20 teeth

// Rounded tooth parameters
tooth_tip_round_r_mm  = 0.55;      // roundness at tooth tip
tooth_root_round_r_mm = 0.35;      // roundness at tooth root corners
tooth_tip_flat_mm     = 0.10;      // small flat to avoid pointy tip

eps = 0.02;

// Derived radii
root_radius_mm = pitch_radius_mm - tooth_root_clearance_mm;
tip_radius_mm  = root_radius_mm + tooth_radial_height_mm;

// 2D helper: rounded polygon via offset (more stable than minkowski for small features)
module rounded_poly(points, r) {
    offset(r=r) offset(delta=-r) polygon(points);
}

// Single tooth as a 3D extrusion, centered at origin, pointing +X (radially outward)
// Profile is a rounded "timing pulley" tooth (not involute gear-like).
module tooth3d() {
    // X = radial, Y = tangential
    // Root starts slightly inside root cylinder to guarantee overlap.
    x_root_in = -tooth_overlap_mm;
    x_tip     = tooth_radial_height_mm;

    // Tangential half-widths:
    // At pitch circle: set by tooth_pitch_thickness_mm
    // At root: slightly wider; at tip: slightly narrower (timing-tooth feel)
    y_pitch = tooth_pitch_thickness_mm/2;
    y_root  = y_pitch * 1.10;
    y_tip   = max(tooth_tip_flat_mm/2, y_pitch * 0.70);

    // Build a smooth-ish tooth using a rounded trapezoid + extra rounding at tip
    linear_extrude(height=pulley_width_mm, center=true, convexity=10) {
        union() {
            // Main body (rounded trapezoid)
            rounded_poly(
                [
                    [x_root_in, -y_root],
                    [x_root_in,  y_root],
                    [x_tip,      y_tip],
                    [x_tip,     -y_tip]
                ],
                tooth_root_round_r_mm
            );

            // Add a rounded cap at the tip to avoid "gear tooth" look
            // (cap overlaps the trapezoid, keeping one connected 2D region)
            translate([x_tip - tooth_tip_round_r_mm*0.35, 0])
                circle(r=tooth_tip_round_r_mm, $fn=48);
        }
    }
}

// Root cylinder (under teeth)
module root_body() {
    cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);
}

// Teeth array placed so that the pitch circle remains at pitch_radius_mm.
// Tooth module is defined with its root at x=0, so translate to root_radius.
module teeth() {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            translate([root_radius_mm, 0, 0])
                tooth3d();
    }
}

// Full pulley solid with bore removed
difference() {
    union() {
        root_body();
        teeth();
    }

    // Bore through entire pulley width (with small extra for clean cut)
    cylinder(r=bore_diameter_mm/2, h=pulley_width_mm + 2*eps, center=true);
}