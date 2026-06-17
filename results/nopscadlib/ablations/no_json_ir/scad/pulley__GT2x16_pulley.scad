$fn = 220;

// -------- Parameters --------
tooth_count        = 16;
pitch_diameter     = 9.75;   // mm (pitch circle diameter)
belt_pitch         = 2;      // mm (GT2 nominal)
pulley_width       = 10;     // mm (toothed section width)
bore_diameter      = 5;      // mm
hub_diameter       = 15;     // mm
hub_length         = 5;      // mm
flange_thickness   = 1;      // mm
set_screw_diameter = 2;      // mm

// Tooth profile (approx GT2-like: rounded tooth with root relief)
// These are visual/printable approximations, not a metrology-accurate GT2 spec.
tooth_height       = 0.75;   // mm radial height above pitch circle
tooth_tip_width    = 0.55;   // mm tangential width at tooth tip
tooth_root_width   = 1.25;   // mm tangential width at tooth root
root_relief        = 0.35;   // mm radial depth below pitch circle between teeth
tooth_overlap      = 0.25;   // mm overlap into body for watertight union

// -------- Derived --------
pitch_r     = pitch_diameter/2;
tooth_angle = 360/tooth_count;

// Radii
outer_r = pitch_r + tooth_height;
root_r  = max(0.1, pitch_r - root_relief);
body_r  = max(0.1, root_r - 0.15); // body slightly under root so valleys are visible

// Flange radius
flange_r = outer_r + 0.8;

// Z placement (computed, no arbitrary offsets)
z_pulley = 0;
z_hub    = -(pulley_width/2 + hub_length/2 - 0.2); // slight overlap into pulley
z_fl_top =  (pulley_width/2 + flange_thickness/2 - 0.15);
z_fl_bot = -(pulley_width/2 + flange_thickness/2 - 0.15);

// -------- Helpers --------
module tooth2d() {
    // 2D tooth cross-section in XY, centered on +X axis direction.
    // Built as a rounded trapezoid using hull of circles.
    // Inner edge starts slightly inside root_r to guarantee union.
    x0 = root_r - tooth_overlap;
    x1 = outer_r;

    // Radii for rounding
    r_tip  = min(0.22, tooth_tip_width/2);
    r_root = min(0.28, tooth_root_width/2);

    hull() {
        translate([x0,  tooth_root_width/2 - r_root]) circle(r=r_root);
        translate([x0, -tooth_root_width/2 + r_root]) circle(r=r_root);
        translate([x1,  tooth_tip_width/2  - r_tip ]) circle(r=r_tip);
        translate([x1, -tooth_tip_width/2  + r_tip ]) circle(r=r_tip);
    }
}

module teeth_ring() {
    // Extrude the 2D tooth around Z with correct count and spacing.
    union() {
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*tooth_angle])
                linear_extrude(height=pulley_width, center=true, convexity=10)
                    tooth2d();
        }
    }
}

module pulley_solid() {
    union() {
        // Main body under the tooth roots
        translate([0,0,z_pulley])
            cylinder(r=body_r, h=pulley_width, center=true);

        // Teeth around circumference (true radial array)
        teeth_ring();

        // Flanges (connected with computed overlap)
        translate([0,0,z_fl_top])
            cylinder(r=flange_r, h=flange_thickness, center=true);
        translate([0,0,z_fl_bot])
            cylinder(r=flange_r, h=flange_thickness, center=true);

        // Hub (connected below pulley with computed overlap)
        translate([0,0,z_hub])
            cylinder(d=hub_diameter, h=hub_length, center=true);
    }
}

module pulley() {
    difference() {
        pulley_solid();

        // Bore through everything
        total_h = pulley_width + hub_length + 2*flange_thickness + 2;
        cylinder(d=bore_diameter, h=total_h, center=true);

        // Set screw holes: radial through hub only (two opposed)
        for (a = [0,180]) {
            rotate([0,0,a])
                translate([0,0,z_hub])
                    rotate([0,90,0])
                        cylinder(d=set_screw_diameter, h=hub_diameter + 2, center=true);
        }
    }
}

// Render
pulley();