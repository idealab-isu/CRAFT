// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Simplified pulley only (no hub extension, no set-screw), one connected solid.

$fn = 200;

// --- Requirements ---
tooth_count    = 20;
pitch_diameter = 12.22;
pitch_radius   = pitch_diameter/2;

// --- Basic geometry (simple flanged pulley) ---
belt_width        = 7;        // toothed section axial length
flange_thickness  = 1.2;
flange_overhang   = 2.0;      // beyond tooth OD

bore_diameter     = 5;

// Tooth proportions (stylized trapezoid teeth; count is exact)
tooth_radial_h    = 1.2;      // tooth height above pitch circle
tooth_root_relief = 0.35;     // root below pitch circle

// --- Derived ---
tooth_pitch   = PI * pitch_diameter / tooth_count;
tooth_outer_r = pitch_radius + tooth_radial_h;
tooth_root_r  = max(0.1, pitch_radius - tooth_root_relief);

flange_diameter = 2*(tooth_outer_r + flange_overhang);
total_h = flange_thickness + belt_width + flange_thickness;

// --- Tooth shape (2D in XY, extruded along Z) ---
module tooth_2d() {
    w_pitch = 0.55 * tooth_pitch;
    w_tip   = 0.28 * tooth_pitch;

    polygon(points=[
        [tooth_root_r, -w_pitch/2],
        [tooth_root_r,  w_pitch/2],
        [tooth_outer_r,  w_tip/2],
        [tooth_outer_r, -w_tip/2]
    ]);
}

module teeth_ring(h) {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            linear_extrude(height=h, center=false)
                tooth_2d();
    }
}

module pulley_solid() {
    union() {
        // Lower flange
        translate([0,0,0])
            cylinder(h=flange_thickness, d=flange_diameter, center=false);

        // Root cylinder (ensures teeth are connected)
        translate([0,0,flange_thickness])
            cylinder(h=belt_width, r=tooth_root_r, center=false);

        // Teeth
        translate([0,0,flange_thickness])
            teeth_ring(belt_width);

        // Upper flange
        translate([0,0,flange_thickness + belt_width])
            cylinder(h=flange_thickness, d=flange_diameter, center=false);
    }
}

difference() {
    pulley_solid();

    // Bore through entire part (slight extra for clean cut)
    translate([0,0,-0.5])
        cylinder(h=total_h + 1, d=bore_diameter, center=false);
}