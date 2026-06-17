$fn = 180;

// Simple parametric timing pulley approximation:
// - 20 teeth
// - pitch diameter = 12.22 mm (given)
// This model approximates tooth form as trapezoidal radial protrusions.
// For accurate belt profiles (GT2/HTD/etc.), replace tooth geometry accordingly.

teeth = 20;
pitch_d = 12.22;          // mm
pitch_r = pitch_d/2;

pulley_width = 10;        // mm
hub_d = 16;               // mm (body OD excluding teeth)
bore_d = 5;               // mm

// Tooth geometry (approximation)
tooth_height = 1.2;       // mm radial height above base OD
tooth_tip_frac = 0.35;    // fraction of tooth angular pitch at tip
tooth_root_frac = 0.75;   // fraction of tooth angular pitch at root

// Base radius chosen so that tooth tips are near pitch radius + small offset.
// This is an approximation; pitch circle is not explicitly enforced by tooth profile.
base_r = max(hub_d/2, pitch_r - 0.6);
tip_r  = base_r + tooth_height;

module tooth2d(a_pitch){
    // Create a trapezoid in polar coordinates (converted to XY points)
    a_root = a_pitch * tooth_root_frac;
    a_tip  = a_pitch * tooth_tip_frac;

    // Points ordered CCW
    pts = [
        [ base_r*cos(-a_root/2), base_r*sin(-a_root/2) ],
        [ tip_r *cos(-a_tip /2), tip_r *sin(-a_tip /2) ],
        [ tip_r *cos( a_tip /2), tip_r *sin( a_tip /2) ],
        [ base_r*cos( a_root/2), base_r*sin( a_root/2) ]
    ];
    polygon(points=pts);
}

module pulley(){
    a_pitch = 360/teeth;

    difference(){
        union(){
            // Main body
            cylinder(h=pulley_width, r=base_r, center=false);

            // Teeth
            for(i=[0:teeth-1]){
                rotate([0,0,i*a_pitch])
                    linear_extrude(height=pulley_width)
                        tooth2d(a_pitch);
            }
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(h=pulley_width+1, d=bore_d, center=false);
    }
}

pulley();