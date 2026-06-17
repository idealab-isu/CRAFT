$fn = 180;

// Timing pulley (approximate GT2-like tooth form)
// User spec: 16 teeth, 12.16mm pitch diameter

teeth = 16;
pitch_d = 12.16;                 // mm
pitch_r = pitch_d/2;

pulley_width = 10;               // mm
bore_d = 5;                      // mm
hub_d = 18;                      // mm
hub_height = 6;                  // mm

// Tooth geometry (approximate)
tooth_depth = 0.75;              // radial height above root
root_clearance = 0.35;           // radial below pitch circle
tooth_tip_round = 0.25;          // mm
tooth_root_round = 0.35;         // mm

pitch = PI * pitch_d / teeth;    // circular pitch along pitch circle
tooth_thickness = 0.48 * pitch;  // along arc at pitch circle (approx)
tooth_angle = tooth_thickness / pitch_r; // radians
tooth_angle_deg = tooth_angle * 180 / PI;

root_r = pitch_r - root_clearance;
tip_r  = root_r + tooth_depth;

module tooth2d() {
    // Build a rounded trapezoid-ish tooth in polar-ish coordinates, then rotate/extrude
    // Construct in XY with center at origin, tooth centered on +X axis.
    // Use hull of circles to get rounded corners.
    a = tooth_angle/2;
    // Points at root and tip along the tooth flanks
    p_root1 = [root_r*cos(-a), root_r*sin(-a)];
    p_root2 = [root_r*cos( a), root_r*sin( a)];
    p_tip1  = [tip_r *cos(-a*0.65), tip_r *sin(-a*0.65)];
    p_tip2  = [tip_r *cos( a*0.65), tip_r *sin( a*0.65)];

    hull() {
        translate(p_root1) circle(r=tooth_root_round);
        translate(p_root2) circle(r=tooth_root_round);
        translate(p_tip1)  circle(r=tooth_tip_round);
        translate(p_tip2)  circle(r=tooth_tip_round);
    }
}

module pulley_body() {
    // Root cylinder (tooth base)
    cylinder(h=pulley_width, r=root_r, center=false);

    // Teeth
    for (i = [0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width)
                tooth2d();
    }

    // Hub (optional)
    translate([0,0,pulley_width])
        cylinder(h=hub_height, r=hub_d/2, center=false);
}

difference() {
    union() {
        pulley_body();
    }
    // Bore through
    translate([0,0,-1])
        cylinder(h=pulley_width + hub_height + 2, r=bore_d/2, center=false);
}