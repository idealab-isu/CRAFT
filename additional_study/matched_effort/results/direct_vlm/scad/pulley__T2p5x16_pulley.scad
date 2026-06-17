$fn = 180;

// Timing pulley with visible teeth
// Requirements: 16 teeth, 12.16mm pitch diameter
teeth   = 16;
pitch_d = 12.16;
pitch_r = pitch_d/2;

pulley_h = 10;      // overall height
bore_d   = 5;       // center bore

// Tooth geometry (simple GT2-like approximation)
tooth_depth  = 0.90;   // radial height above root
root_clear   = 0.35;   // pitch circle to root
tooth_tip_w  = 0.70;   // tangential width at tip
tooth_root_w = 1.55;   // tangential width at root

// Derived radii
root_r = pitch_r - root_clear;
tip_r  = root_r + tooth_depth;

// Ensure teeth are not hidden by an oversized hub.
// Hub is kept slightly inside the root diameter so teeth remain visible.
hub_d = min(2*(root_r - 0.20), 2*root_r);
hub_h = pulley_h;

module tooth2d() {
    // Trapezoid centered on +X axis (radial direction), Y is tangential
    polygon(points=[
        [root_r, -tooth_root_w/2],
        [root_r,  tooth_root_w/2],
        [tip_r,   tooth_tip_w/2],
        [tip_r,  -tooth_tip_w/2]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Root cylinder (tooth base)
            cylinder(h=pulley_h, r=root_r, center=false);

            // Teeth (radial array)
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    linear_extrude(height=pulley_h)
                        tooth2d();
            }

            // Hub (kept inside root so it doesn't cover teeth)
            cylinder(h=hub_h, d=hub_d, center=false);
        }

        // Bore (slightly extended to guarantee through-cut)
        translate([0,0,-0.5])
            cylinder(h=pulley_h+1, d=bore_d, center=false);
    }
}

pulley();