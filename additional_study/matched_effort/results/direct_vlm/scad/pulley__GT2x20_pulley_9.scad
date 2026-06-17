$fn = 180;

// Timing pulley: 20 teeth, 12.22mm pitch diameter
teeth   = 20;
pitch_d = 12.22;                 // mm (pitch diameter)
pitch_r = pitch_d/2;
pitch   = PI * pitch_d / teeth;  // circular pitch (mm)

pulley_width = 10;               // mm
bore_d       = 5;                // mm

// Groove geometry (timing-belt tooth space), robust boolean-friendly
groove_depth = 0.75;             // radial depth (mm)
groove_open  = pitch * 0.55;     // width at OD (mm)
groove_root  = pitch * 0.25;     // width at groove bottom (mm)

// Ensure pitch circle is centered in groove depth:
// pitch_r = outer_r - groove_depth/2  => outer_r = pitch_r + groove_depth/2
outer_r = pitch_r + groove_depth/2;
root_r  = outer_r - groove_depth;

eps = 0.05;

// Convert chord width at radius r to included angle (degrees)
function chord_to_deg(w, r) = 2 * asin(min(1, (w/2)/r)) * 180 / PI;

module groove2d() {
    // Trapezoid groove centered on +X axis, spanning from root_r to outer_r
    ang_outer = chord_to_deg(groove_open, outer_r);
    ang_root  = chord_to_deg(groove_root, root_r);

    polygon(points=[
        [root_r  * cos(-ang_root/2),  root_r  * sin(-ang_root/2)],
        [outer_r * cos(-ang_outer/2), outer_r * sin(-ang_outer/2)],
        [outer_r * cos( ang_outer/2), outer_r * sin( ang_outer/2)],
        [root_r  * cos( ang_root/2),  root_r  * sin( ang_root/2)]
    ]);
}

module pulley2d() {
    difference() {
        circle(r=outer_r);

        // Cut grooves; slightly extend radially to avoid coincident edges
        for (i = [0:teeth-1]) {
            rotate(i * 360 / teeth)
                offset(delta=eps)
                    groove2d();
        }
    }
}

module pulley() {
    difference() {
        linear_extrude(height=pulley_width, center=true, convexity=10)
            pulley2d();

        // Bore (through), slightly longer to guarantee clean subtraction
        cylinder(d=bore_d, h=pulley_width + 2, center=true);
    }
}

pulley();