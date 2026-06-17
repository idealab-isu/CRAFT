// Timing pulley: 12 teeth, pitch diameter = 7.15mm
// Fix: make teeth clearly visible by CUTTING tooth gaps (timing pulley style),
// and keep pitch diameter authoritative.

$fn = 220;

// ---- Inputs ----
tooth_count         = 12;
pitch_diameter_mm   = 7.15;          // REQUIRED

pulley_width_mm     = 6;

tooth_height_mm     = 0.75;          // radial depth of tooth space (from root to pitch circle region)
tooth_root_clear_mm = 0.35;          // radial amount below pitch circle to root

tooth_arc_frac      = 0.55;          // fraction of tooth pitch occupied by tooth at pitch circle (0..1)

bore_diameter_mm    = 3;

hub_diameter_mm     = 10;
hub_length_mm       = 10;

flange_diameter_mm  = 12;
flange_thickness_mm = 1.2;

overlap_mm          = 0.20;          // overlap for watertight unions/differences

// ---- Derived ----
pitch_r = pitch_diameter_mm/2;
root_r  = pitch_r - tooth_root_clear_mm;     // root circle radius (valleys)
outer_r = root_r + tooth_height_mm;          // tooth tip circle radius (lands)

tooth_pitch_angle = 360/tooth_count;
tooth_angle       = tooth_pitch_angle * tooth_arc_frac;

// ---- Helpers ----
module annular_sector(r1, r2, ang_deg, h) {
    // 2D annular sector extruded to height h, centered on +X axis
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[
            [ r1*cos(-ang_deg/2), r1*sin(-ang_deg/2) ],
            [ r2*cos(-ang_deg/2), r2*sin(-ang_deg/2) ],
            [ r2*cos( ang_deg/2), r2*sin( ang_deg/2) ],
            [ r1*cos( ang_deg/2), r1*sin( ang_deg/2) ]
        ]);
}

module toothed_rim() {
    // Build a toothed ring by subtracting tooth gaps from an outer cylinder.
    // This guarantees visible tooth count in top/bottom views.
    difference() {
        // Outer land cylinder (tooth tips)
        cylinder(r=outer_r, h=pulley_width_mm, center=true);

        // Tooth gaps (valleys) cut down to root_r
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*tooth_pitch_angle + tooth_pitch_angle/2])  // center gaps between lands
                annular_sector(root_r - overlap_mm, outer_r + overlap_mm,
                               (tooth_pitch_angle - tooth_angle), pulley_width_mm + 2*overlap_mm);
        }
    }
}

module pulley_body() {
    union() {
        // Hub (longer than toothed section)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Toothed rim (centered)
        toothed_rim();

        // Flanges (connected with slight overlap)
        translate([0,0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0,0,-pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

difference() {
    pulley_body();

    // Round bore through entire part (hub + flanges) with overlap
    cylinder(r=bore_diameter_mm/2,
             h=hub_length_mm + 2*flange_thickness_mm + 6*overlap_mm,
             center=true);
}