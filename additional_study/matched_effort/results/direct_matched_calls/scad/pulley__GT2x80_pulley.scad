$fn = 160;

// Timing pulley parameters
teeth = 80;
pitch_d = 50.42;          // mm (given)
pitch = PI * pitch_d / teeth;

pulley_width = 12;        // mm
bore_d = 5;               // mm
hub_d = 18;               // mm
hub_len = 16;             // mm

// Tooth geometry (generic trapezoid approximation)
tooth_height = 1.6;       // mm (radial)
tooth_top_w = 0.55 * pitch;
tooth_base_w = 0.95 * pitch;

// Body radii
r_pitch = pitch_d/2;
r_root  = r_pitch - 0.9*tooth_height;
r_outer = r_pitch + 0.7*tooth_height;

module tooth2d() {
    // Trapezoid centered on +X axis, base at x=0, extends to +X
    polygon(points=[
        [0, -tooth_base_w/2],
        [0,  tooth_base_w/2],
        [tooth_height,  tooth_top_w/2],
        [tooth_height, -tooth_top_w/2]
    ]);
}

module pulley_teeth() {
    for (i = [0:teeth-1]) {
        rotate(i * 360/teeth)
            translate([r_root, 0, 0])
                linear_extrude(height=pulley_width, center=true, convexity=10)
                    tooth2d();
    }
}

module pulley_body() {
    // Root cylinder + teeth union
    union() {
        cylinder(h=pulley_width, r=r_root, center=true);
        pulley_teeth();
    }
}

module hub() {
    // Simple hub centered, slightly longer than pulley
    cylinder(h=hub_len, r=hub_d/2, center=true);
}

module bore() {
    cylinder(h=hub_len + 2, r=bore_d/2, center=true);
}

difference() {
    union() {
        pulley_body();
        hub();
    }
    bore();
}