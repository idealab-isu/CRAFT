$fn = 160;

// Timing pulley parameters
teeth = 16;
pitch_d = 9.75;          // mm (pitch diameter)
pitch_r = pitch_d/2;

pulley_h = 12;           // overall height
bore_d = 5;              // center bore diameter
hub_d = 14;              // hub diameter
hub_h = 12;              // hub height (same as pulley for simplicity)

flange_d = 18;           // flange outer diameter
flange_h = 1.2;          // flange thickness (top and bottom)

tooth_radial = 1.2;      // tooth height above pitch radius
tooth_width = 1.6;       // tangential width at pitch circle
tooth_tip_width = 0.9;   // tangential width at tooth tip
tooth_root_clear = 0.6;  // root below pitch radius

root_r = max(0.1, pitch_r - tooth_root_clear);
outer_r = pitch_r + tooth_radial;

module tooth2d() {
    // A simple trapezoidal tooth profile centered on +X axis
    polygon(points=[
        [root_r, -tooth_width/2],
        [root_r,  tooth_width/2],
        [outer_r,  tooth_tip_width/2],
        [outer_r, -tooth_tip_width/2]
    ]);
}

module pulley_body() {
    // Main toothed cylinder (root diameter)
    union() {
        cylinder(h=pulley_h, r=root_r);

        // Teeth
        for (i = [0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                linear_extrude(height=pulley_h)
                    tooth2d();
        }

        // Flanges
        translate([0,0,0])
            cylinder(h=flange_h, d=flange_d);
        translate([0,0,pulley_h-flange_h])
            cylinder(h=flange_h, d=flange_d);

        // Hub (optional, same height)
        cylinder(h=hub_h, d=hub_d);
    }
}

difference() {
    pulley_body();
    // Bore
    translate([0,0,-0.5])
        cylinder(h=pulley_h+1, d=bore_d);
}