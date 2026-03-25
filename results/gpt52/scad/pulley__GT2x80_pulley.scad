$fn=128;

teeth = 80;
pitch_d = 50.42;          // mm
pitch_r = pitch_d/2;

pulley_width = 12;        // mm
hub_d = 28;               // mm
bore_d = 8;               // mm

// Approximate GT2-like tooth geometry (parametric, not standard-verified)
tooth_height = 1.6;       // mm radial height above pitch radius
tooth_base_thickness = 1.2; // mm tangential thickness at base
tooth_top_thickness  = 0.6; // mm tangential thickness at top

root_clearance = 0.8;     // mm below pitch radius
root_r = pitch_r - root_clearance;
outer_r = pitch_r + tooth_height;

module tooth2d(rb, rt, tb, tt) {
    polygon(points=[
        [rb, -tb/2],
        [rb,  tb/2],
        [rt,  tt/2],
        [rt, -tt/2]
    ]);
}

module teeth_ring() {
    for (i = [0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d(pitch_r, outer_r, tooth_base_thickness, tooth_top_thickness);
    }
}

module pulley_body() {
    union() {
        cylinder(h=pulley_width, r=root_r, center=true);
        teeth_ring();
        cylinder(h=pulley_width, d=hub_d, center=true);
    }
}

difference() {
    pulley_body();
    cylinder(h=pulley_width+2, d=bore_d, center=true);
}