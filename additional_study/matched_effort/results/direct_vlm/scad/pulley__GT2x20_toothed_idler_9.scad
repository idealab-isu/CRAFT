$fn = 220;

// Timing pulley: 20 teeth, 12.22mm pitch diameter
teeth   = 20;
pitch_d = 12.22;                 // mm
pitch_r = pitch_d/2;

pulley_width = 10;               // mm
hub_d        = 18;               // mm
hub_height   = pulley_width;     // mm
bore_d       = 5;                // mm

// Tooth geometry (simple timing-tooth approximation)
tooth_height     = 0.75;         // radial height above pitch circle (mm)
tooth_root_depth = 0.35;         // radial depth below pitch circle (mm)
tooth_tip_flat   = 0.55;         // tangential width at tip (mm)
tooth_root_flat  = 1.10;         // tangential width at root (mm)
tooth_fillet     = 0.18;         // corner rounding (mm)

// Derived radii
outer_r = pitch_r + tooth_height;
root_r  = max(0.1, pitch_r - tooth_root_depth);

// Make the pulley body reach the tooth root so teeth are visible and connected
tooth_overlap = 0.25;            // overlap into body for watertight union
body_r = root_r + tooth_overlap; // IMPORTANT: body extends to (slightly past) root radius

tooth_angle = 360 / teeth;

module rounded_tooth_2d() {
    // Tooth profile in XY: X is radial distance from center, Y is tangential
    pts = [
        [root_r, -tooth_root_flat/2],
        [root_r,  tooth_root_flat/2],
        [outer_r,  tooth_tip_flat/2],
        [outer_r, -tooth_tip_flat/2]
    ];
    offset(r=tooth_fillet) offset(delta=-tooth_fillet)
        polygon(points=pts);
}

module pulley_body() {
    cylinder(h=pulley_width, r=body_r, center=false);
}

module teeth_ring() {
    for (i = [0:teeth-1]) {
        rotate([0,0,i*tooth_angle])
            linear_extrude(height=pulley_width, center=false, convexity=10)
                rounded_tooth_2d();
    }
}

module hub() {
    cylinder(h=hub_height, d=hub_d, center=false);
}

module bore() {
    translate([0,0,-1])
        cylinder(h=pulley_width+2, d=bore_d, center=false);
}

difference() {
    union() {
        hub();
        pulley_body();
        teeth_ring();
    }
    bore();
}