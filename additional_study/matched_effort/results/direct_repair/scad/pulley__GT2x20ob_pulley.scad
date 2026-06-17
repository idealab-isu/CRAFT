$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// User specs:
teeth = 20;
pitch_d = 12.22;          // mm pitch diameter
pitch_r = pitch_d/2;

// Assumptions / typical defaults (editable):
belt_pitch = PI * pitch_d / teeth;   // derived from pitch diameter & tooth count
pulley_width = 10;                   // mm
bore_d = 5;                          // mm
hub_d = 0;                           // 0 = no hub
hub_h = 0;                           // mm

// Tooth geometry (simplified trapezoid, sized relative to pitch)
tooth_height = 0.75;                 // mm radial height above pitch circle
tooth_root_depth = 0.35;             // mm radial depth below pitch circle (for valleys)
tooth_top_frac = 0.35;               // fraction of pitch for tooth top width
tooth_base_frac = 0.65;              // fraction of pitch for tooth base width

// Derived radii
outer_r = pitch_r + tooth_height;
root_r  = pitch_r - tooth_root_depth;

// Safety
root_r_safe = max(root_r, bore_d/2 + 0.8);

// Tooth angular widths
tooth_top_w  = belt_pitch * tooth_top_frac;
tooth_base_w = belt_pitch * tooth_base_frac;

tooth_top_ang  = tooth_top_w  / pitch_r * 180/PI;
tooth_base_ang = tooth_base_w / pitch_r * 180/PI;

module tooth2d() {
    // Trapezoid centered on +X axis, spanning angles around 0
    polygon(points=[
        [root_r_safe*cos(-tooth_base_ang/2), root_r_safe*sin(-tooth_base_ang/2)],
        [outer_r*cos(-tooth_top_ang/2),      outer_r*sin(-tooth_top_ang/2)],
        [outer_r*cos( tooth_top_ang/2),      outer_r*sin( tooth_top_ang/2)],
        [root_r_safe*cos( tooth_base_ang/2), root_r_safe*sin( tooth_base_ang/2)]
    ]);
}

module pulley_body() {
    // Base cylinder up to root radius
    cylinder(h=pulley_width, r=root_r_safe, center=false);

    // Teeth ring
    for(i=[0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width)
                tooth2d();
    }

    // Optional hub
    if(hub_d > 0 && hub_h > 0) {
        translate([0,0,(pulley_width-hub_h)/2])
            cylinder(h=hub_h, r=hub_d/2, center=false);
    }
}

difference() {
    pulley_body();
    // Bore
    translate([0,0,-1])
        cylinder(h=pulley_width+2, r=bore_d/2, center=false);
}