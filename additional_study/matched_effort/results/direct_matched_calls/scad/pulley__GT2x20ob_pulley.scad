$fn = 180;

// Timing pulley (approximate GT2-like tooth form)
// User spec: 20 teeth, 12.22mm pitch diameter

teeth = 20;
pitch_d = 12.22;                 // mm
pitch_r = pitch_d/2;

pulley_width = 10;               // mm
bore_d = 5;                      // mm

// Tooth geometry (approximate)
tooth_height = 0.75;             // radial height above pitch circle (mm)
tooth_tip_flat = 0.55;           // mm (arc-length at tip, approximated as chord)
tooth_root_flat = 1.10;          // mm (arc-length at root, approximated as chord)
root_clearance = 0.35;           // radial below pitch circle (mm)

// Derived radii
r_tip  = pitch_r + tooth_height;
r_root = max(0.1, pitch_r - root_clearance);

// Angular pitch
tooth_ang = 360 / teeth;

// Convert desired chord length at radius to half-angle (degrees)
function halfang_from_chord(chord, r) = (r <= 0) ? 0 : asin(min(1, chord/(2*r))) * 180 / PI;

tip_halfang  = halfang_from_chord(tooth_tip_flat,  r_tip);
root_halfang = halfang_from_chord(tooth_root_flat, r_root);

// Base body radius (to support roots)
body_r = r_root;

// Small fillet approximation via extra points
fillet_ang = min( (root_halfang - tip_halfang) * 0.35, tooth_ang*0.08 );
fillet_ang = max(fillet_ang, 0.2);

module tooth2d() {
    // One tooth centered at angle 0, defined in polar-ish coordinates
    // Polygon points in CCW order
    polygon(points=[
        [ r_root*cos(-root_halfang), r_root*sin(-root_halfang) ],
        [ r_root*cos(-tip_halfang - fillet_ang), r_root*sin(-tip_halfang - fillet_ang) ],
        [ r_tip *cos(-tip_halfang),  r_tip *sin(-tip_halfang)  ],
        [ r_tip *cos( tip_halfang),  r_tip *sin( tip_halfang)  ],
        [ r_root*cos( tip_halfang + fillet_ang), r_root*sin( tip_halfang + fillet_ang) ],
        [ r_root*cos( root_halfang), r_root*sin( root_halfang) ]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Root cylinder
            cylinder(h=pulley_width, r=body_r, center=true);

            // Teeth
            for (i=[0:teeth-1]) {
                rotate([0,0,i*tooth_ang])
                    linear_extrude(height=pulley_width, center=true)
                        tooth2d();
            }
        }

        // Bore
        cylinder(h=pulley_width+2, r=bore_d/2, center=true);
    }
}

pulley();