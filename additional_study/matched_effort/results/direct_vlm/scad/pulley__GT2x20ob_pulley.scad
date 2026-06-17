$fn = 180;

// Timing pulley (connected solid)
// Requirements:
// - 20 teeth
// - pitch diameter = 12.22 mm

teeth = 20;
pitch_d = 12.22;          // mm
pulley_width = 10;        // mm (toothed section width, excluding flanges)
bore_d = 5;               // mm

// Tooth geometry (approximation)
tooth_height = 0.9;       // mm radial height above pitch circle
valley_depth = 0.6;       // mm radial depth below pitch circle

// Make teeth clearly visible in side views by using a wider angular tooth at the tip
tooth_tip_arc_frac  = 0.70; // fraction of tooth pitch occupied by tooth at tip radius
tooth_root_arc_frac = 0.35; // fraction of tooth pitch occupied by tooth at pitch radius

// Flanges
flange_thickness = 1.0;   // mm each side
flange_overhang = 1.0;    // mm radial beyond tooth OD

// Small overlaps to guarantee manifold unions/differences
eps = 0.03;

module tooth_wedge(pitch_r, tip_r, ang_root, ang_tip, h) {
    linear_extrude(height=h, center=false, convexity=10)
        polygon(points=[
            [ pitch_r*cos(-ang_root/2), pitch_r*sin(-ang_root/2) ],
            [ pitch_r*cos( ang_root/2), pitch_r*sin( ang_root/2) ],
            [ tip_r  *cos( ang_tip/2),  tip_r  *sin( ang_tip/2)  ],
            [ tip_r  *cos(-ang_tip/2),  tip_r  *sin(-ang_tip/2)  ]
        ]);
}

module timing_pulley(teeth, pitch_d, width, bore_d) {
    pitch_r = pitch_d/2;
    root_r  = max(0.1, pitch_r - valley_depth);
    tip_r   = pitch_r + tooth_height;

    pitch_ang = 360 / teeth;
    ang_tip   = pitch_ang * tooth_tip_arc_frac;
    ang_root  = pitch_ang * tooth_root_arc_frac;

    flange_r = tip_r + flange_overhang;
    total_h  = width + 2*flange_thickness;

    difference() {
        union() {
            // Base body up to pitch radius (solid under teeth)
            cylinder(h=total_h, r=pitch_r, center=false);

            // Teeth: protrude from pitch radius to tip radius, full height
            for (i = [0:teeth-1]) {
                rotate([0,0,i*pitch_ang])
                    tooth_wedge(pitch_r=pitch_r, tip_r=tip_r, ang_root=ang_root, ang_tip=ang_tip, h=total_h);
            }

            // Flanges (connected; slight overlap)
            if (flange_thickness > 0) {
                // Bottom flange
                cylinder(h=flange_thickness + eps, r=flange_r, center=false);

                // Top flange
                translate([0,0,total_h - flange_thickness - eps])
                    cylinder(h=flange_thickness + eps, r=flange_r, center=false);
            }
        }

        // Cut valleys between teeth down to root radius (creates visible tooth gaps)
        for (i = [0:teeth-1]) {
            rotate([0,0,i*pitch_ang + pitch_ang/2])
                linear_extrude(height=total_h + 2*eps, center=false, convexity=10)
                    polygon(points=[
                        [ 0, 0 ],
                        [ pitch_r*cos(-pitch_ang*(1-tooth_root_arc_frac)/2), pitch_r*sin(-pitch_ang*(1-tooth_root_arc_frac)/2) ],
                        [ root_r *cos(-pitch_ang*(1-tooth_root_arc_frac)/2), root_r *sin(-pitch_ang*(1-tooth_root_arc_frac)/2) ],
                        [ root_r *cos( pitch_ang*(1-tooth_root_arc_frac)/2), root_r *sin( pitch_ang*(1-tooth_root_arc_frac)/2) ],
                        [ pitch_r*cos( pitch_ang*(1-tooth_root_arc_frac)/2), pitch_r*sin( pitch_ang*(1-tooth_root_arc_frac)/2) ]
                    ]);
        }

        // Bore through entire part
        translate([0,0,-eps])
            cylinder(h=total_h + 2*eps, r=bore_d/2, center=false);
    }
}

timing_pulley(teeth=teeth, pitch_d=pitch_d, width=pulley_width, bore_d=bore_d);