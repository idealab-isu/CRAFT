$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// Specs requested: 10 teeth, 15.0mm pitch diameter
teeth = 10;
pitch_d = 15.0;          // mm
pulley_w = 10.0;         // mm (default)
bore_d = 5.0;            // mm (default)
hub_d = 0;               // 0 = no hub
hub_w = 0;

pitch_r = pitch_d/2;
pitch_circ = PI * pitch_d;
pitch = pitch_circ / teeth;

// Approximate GT2 tooth geometry (simplified)
tooth_height = 0.75;     // radial height above pitch circle (mm)
tooth_root_depth = 0.35; // radial depth below pitch circle (mm)
tooth_tip_w = 0.55 * pitch;
tooth_base_w = 0.95 * pitch;

// Derived radii
r_root = pitch_r - tooth_root_depth;
r_tip  = pitch_r + tooth_height;

// Ensure sane radii
r_root = max(0.1, r_root);

module tooth2d() {
    // A simple trapezoid tooth centered on +X axis, extruded later
    // Base at pitch circle, tip outward
    polygon(points=[
        [pitch_r, -tooth_base_w/2],
        [pitch_r,  tooth_base_w/2],
        [r_tip,    tooth_tip_w/2],
        [r_tip,   -tooth_tip_w/2]
    ]);
}

module pulley_body() {
    // Root cylinder + teeth union
    union() {
        cylinder(h=pulley_w, r=r_root, center=true);

        for (i = [0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                linear_extrude(height=pulley_w, center=true)
                    tooth2d();
        }

        if (hub_d > 0 && hub_w > 0) {
            translate([0,0,0])
                cylinder(h=hub_w, r=hub_d/2, center=true);
        }
    }
}

difference() {
    pulley_body();
    // Bore
    cylinder(h=pulley_w + 2, r=bore_d/2, center=true);
}