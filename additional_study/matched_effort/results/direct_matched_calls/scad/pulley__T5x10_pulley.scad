$fn = 180;

// Timing pulley (simplified) with 10 teeth and 15.0mm pitch diameter
// Assumes trapezoidal tooth approximation around pitch circle.

teeth = 10;
pitch_d = 15.0;          // mm
pitch_r = pitch_d/2;

pulley_width = 10;       // mm
hub_d = 18;              // mm (body OD, slightly larger than pitch)
bore_d = 5;              // mm

// Tooth geometry (approx)
tooth_height = 1.6;      // radial height above pitch circle
tooth_root_depth = 0.6;  // radial depth below pitch circle (into body)
tooth_tip_arc_frac = 0.45; // fraction of tooth pitch occupied by tip width
tooth_root_arc_frac = 0.85; // fraction of tooth pitch occupied by root width

pitch_circ = PI * pitch_d;
tooth_pitch = pitch_circ / teeth;
tooth_pitch_angle = 360 / teeth;

module tooth2d() {
    // Build a trapezoid in polar-ish coordinates around pitch circle:
    // inner radius at (pitch_r - tooth_root_depth), outer at (pitch_r + tooth_height)
    // widths are expressed as arc lengths at pitch radius, converted to angles.
    inner_r = pitch_r - tooth_root_depth;
    outer_r = pitch_r + tooth_height;

    tip_w = tooth_pitch * tooth_tip_arc_frac;
    root_w = tooth_pitch * tooth_root_arc_frac;

    tip_ang = (tip_w / pitch_r) * 180 / PI;
    root_ang = (root_w / pitch_r) * 180 / PI;

    // Points defined in XY using angles about origin
    function pt(r,a) = [r*cos(a), r*sin(a)];

    polygon(points=[
        pt(inner_r, -root_ang/2),
        pt(outer_r, -tip_ang/2),
        pt(outer_r,  tip_ang/2),
        pt(inner_r,  root_ang/2)
    ]);
}

module pulley() {
    difference() {
        union() {
            // Base cylinder (body)
            cylinder(d=hub_d, h=pulley_width, center=true);

            // Teeth ring
            for (i = [0:teeth-1]) {
                rotate([0,0,i*tooth_pitch_angle])
                    linear_extrude(height=pulley_width, center=true)
                        tooth2d();
            }
        }

        // Bore
        cylinder(d=bore_d, h=pulley_width+2, center=true);
    }
}

pulley();