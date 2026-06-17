$fn = 180;

// Timing pulley (approximate) with 16 teeth and 9.75mm pitch diameter.
// This is a simplified, renderable model: cylindrical body + rectangular teeth.
// Parameters are editable.

teeth = 16;
pitch_d = 9.75;                 // pitch diameter (mm)
pitch_r = pitch_d/2;

pulley_width = 10;              // overall width (mm)
bore_d = 5;                     // center bore (mm)

tooth_height = 1.2;             // radial height above pitch circle (mm)
tooth_root_depth = 0.6;         // radial depth below pitch circle (mm)
tooth_arc_fraction = 0.45;      // fraction of tooth pitch occupied by tooth at pitch radius
tooth_tip_taper = 0.85;         // tip width factor vs base width (0..1)

hub_extra_r = 0.0;              // optional extra radius for hub (mm), 0 = none

// Derived
pitch_circ = PI * pitch_d;
tooth_pitch = pitch_circ / teeth;                 // arc length per tooth at pitch circle
tooth_base_w = tooth_pitch * tooth_arc_fraction;  // chord approx via arc length (small angles)
tooth_tip_w  = tooth_base_w * tooth_tip_taper;

r_root = max(0.1, pitch_r - tooth_root_depth);
r_body = pitch_r;                                 // body up to pitch circle
r_tip  = pitch_r + tooth_height;
r_hub  = r_tip + hub_extra_r;

module tooth_2d() {
    // Trapezoid centered on X axis, extending from r_body to r_tip in Y
    polygon(points=[
        [-tooth_base_w/2, r_body],
        [ tooth_base_w/2, r_body],
        [ tooth_tip_w/2,  r_tip ],
        [-tooth_tip_w/2,  r_tip ]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Root cylinder (below pitch circle)
            cylinder(h=pulley_width, r=r_root);

            // Body cylinder up to pitch circle
            cylinder(h=pulley_width, r=r_body);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    linear_extrude(height=pulley_width)
                        tooth_2d();
            }

            // Optional hub (if hub_extra_r > 0)
            if (hub_extra_r > 0)
                cylinder(h=pulley_width, r=r_hub);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(h=pulley_width+1, d=bore_d);
    }
}

pulley();