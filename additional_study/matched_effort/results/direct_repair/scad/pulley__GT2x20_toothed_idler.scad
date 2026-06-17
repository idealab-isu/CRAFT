$fn=160;

// Timing pulley parameters
teeth = 20;
pitch_d = 12.22;          // mm
pitch = PI * pitch_d / teeth;

pulley_width = 10;        // mm
hub_d = 16;               // mm (outer diameter of pulley body)
bore_d = 5;               // mm (shaft bore)

tooth_height = 1.2;       // mm radial height above body
tooth_tip_width = 0.9;    // mm tangential width at tip
tooth_root_width = 1.6;   // mm tangential width at root

// Derived
pitch_r = pitch_d/2;
body_r = pitch_r - 0.6;   // place pitch circle slightly above body
outer_r = body_r + tooth_height;

module tooth2d() {
    // Simple trapezoidal tooth profile in XY, centered on +X axis
    // Root at x=body_r, tip at x=outer_r
    polygon(points=[
        [body_r, -tooth_root_width/2],
        [body_r,  tooth_root_width/2],
        [outer_r,  tooth_tip_width/2],
        [outer_r, -tooth_tip_width/2]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Main body
            cylinder(h=pulley_width, r=body_r, center=false);

            // Teeth
            for (i=[0:teeth-1]) {
                rotate([0,0,i*360/teeth])
                    linear_extrude(height=pulley_width, center=false)
                        tooth2d();
            }

            // Slight flanges (optional, subtle)
            flange_h = 0.6;
            flange_r = body_r + 0.4;
            translate([0,0,0]) cylinder(h=flange_h, r=flange_r);
            translate([0,0,pulley_width-flange_h]) cylinder(h=flange_h, r=flange_r);
        }

        // Bore
        translate([0,0,-1]) cylinder(h=pulley_width+2, r=bore_d/2);
    }
}

pulley();