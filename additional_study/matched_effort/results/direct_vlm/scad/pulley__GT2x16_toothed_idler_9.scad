$fn = 180;

// Timing pulley with visible teeth
teeth   = 16;
pitch_d = 9.75;                 // mm pitch diameter (at tooth pitch circle)
pitch_r = pitch_d/2;
pitch   = PI * pitch_d / teeth; // circular pitch

pulley_width = 10;              // mm (toothed section width between flanges)
hub_d        = 14;              // mm (root/body diameter under teeth)
bore_d       = 5;               // mm (shaft hole)
flange_d     = 18;              // mm
flange_th    = 1.2;             // mm

// Tooth geometry (simple, clearly visible)
tooth_height     = 0.90;        // mm radial height above pitch circle
tooth_tip_width  = 0.55 * pitch;
tooth_root_width = 0.90 * pitch;
tooth_round      = 0.18;        // mm rounding radius

root_r  = hub_d/2;
outer_r = pitch_r + tooth_height;

// Ensure teeth connect to hub by overlapping into it
tooth_overlap = max(0.35, (pitch_r - root_r) + 0.35); // mm overlap into hub

module rounded_trapezoid_2d(w_top, w_bot, h, r=0.2) {
    // Centered on X, base at y=0, top at y=h
    offset(r=r)
        offset(delta=-r)
            polygon(points=[
                [-w_bot/2, 0],
                [ w_bot/2, 0],
                [ w_top/2, h],
                [-w_top/2, h]
            ]);
}

module tooth_3d() {
    // Build tooth in XY with radial direction = +Y, then place at pitch radius.
    // Inner edge radius = pitch_r - tooth_overlap (inside hub), outer edge protrudes outward.
    translate([0, pitch_r - tooth_overlap, 0])
        linear_extrude(height=pulley_width, center=true, convexity=10)
            rounded_trapezoid_2d(tooth_tip_width, tooth_root_width, tooth_height, tooth_round);
}

module pulley_body() {
    union() {
        // Root cylinder under teeth
        cylinder(r=root_r, h=pulley_width, center=true);

        // Flanges connected to body (slight overlap)
        translate([0, 0, pulley_width/2 + flange_th/2 - 0.2])
            cylinder(d=flange_d, h=flange_th, center=true);
        translate([0, 0, -(pulley_width/2 + flange_th/2 - 0.2)])
            cylinder(d=flange_d, h=flange_th, center=true);
    }
}

module pulley_teeth() {
    for (i = [0:teeth-1])
        rotate([0, 0, i*360/teeth])
            tooth_3d();
}

difference() {
    union() {
        pulley_body();
        pulley_teeth();
    }

    // Bore through entire part
    cylinder(d=bore_d, h=pulley_width + 2*flange_th + 6, center=true);
}