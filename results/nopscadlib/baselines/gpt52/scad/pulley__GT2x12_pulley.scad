$fn=128;

teeth = 12;
pitch_d = 7.15;          // mm
pitch_r = pitch_d/2;

pulley_h = 8;            // mm
bore_d = 3.0;            // mm

// Approximate tooth geometry (simple trapezoidal teeth)
tooth_radial = 0.8;      // mm outward from pitch radius
tooth_root_inset = 0.4;  // mm inward from pitch radius
tooth_tangential = 1.2;  // mm width at pitch circle (approx)
tooth_top_tangential = 0.7; // mm width at tooth tip (approx)

root_r = max(0.1, pitch_r - tooth_root_inset);
outer_r = pitch_r + tooth_radial;

module tooth_2d() {
    // Trapezoid centered on +X axis, extruded later
    polygon(points=[
        [root_r, -tooth_tangential/2],
        [root_r,  tooth_tangential/2],
        [outer_r,  tooth_top_tangential/2],
        [outer_r, -tooth_top_tangential/2]
    ]);
}

module teeth_ring() {
    for(i=[0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_h, center=true)
                tooth_2d();
    }
}

module body() {
    cylinder(h=pulley_h, r=root_r, center=true, $fn=128);
}

module pulley() {
    difference() {
        union() {
            body();
            teeth_ring();
        }
        cylinder(h=pulley_h+2, d=bore_d, center=true, $fn=96);
    }
}

pulley();