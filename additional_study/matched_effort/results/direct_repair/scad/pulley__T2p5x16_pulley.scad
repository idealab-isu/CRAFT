$fn = 180;

// Timing pulley (approximate GT2-like tooth form)
// Specs: 16 teeth, pitch diameter 12.16mm
teeth = 16;
pitch_d = 12.16;
pitch_r = pitch_d/2;

pulley_width = 10;          // mm
hub_d = 18;                 // mm
hub_height = pulley_width;  // mm

bore_d = 5;                 // mm

// Tooth geometry (approximate)
tooth_height = 0.75;        // radial height above pitch circle
tooth_tip_width = 1.10;     // tangential width at tip
tooth_root_width = 1.60;    // tangential width at base
tooth_fillet = 0.25;        // rounding for tooth polygon corners

// Derived
pitch_circ = PI * pitch_d;
tooth_pitch = pitch_circ / teeth;
tooth_angle = 360 / teeth;

// Root radius chosen so that tooth top reaches ~pitch_r + tooth_height
root_r = pitch_r - 0.35; // small offset so pitch circle lies within tooth body
tip_r  = root_r + tooth_height;

// Ensure tooth widths are not larger than available pitch
tooth_tip_w  = min(tooth_tip_width, 0.85*tooth_pitch);
tooth_root_w = min(tooth_root_width, 0.95*tooth_pitch);

// Base cylinder radius (root circle)
base_r = root_r;

// Helper: rounded 2D polygon via offset
module rounded_polygon(points, r=0.2) {
    offset(r=r) offset(delta=-r) polygon(points);
}

// Single tooth as a 3D extrusion centered on X axis, extending in +Y radial direction
module tooth3d(width) {
    // Tooth profile in local coordinates:
    // y is radial, x is tangential
    pts = [
        [-tooth_root_w/2, 0],
        [ tooth_root_w/2, 0],
        [ tooth_tip_w/2,  tooth_height],
        [-tooth_tip_w/2,  tooth_height]
    ];
    linear_extrude(height=width, center=true, convexity=10)
        translate([0, base_r])
            rounded_polygon(pts, r=tooth_fillet);
}

module pulley() {
    difference() {
        union() {
            // Hub/body
            cylinder(h=hub_height, r=hub_d/2, center=true);

            // Root cylinder (ensures continuous root circle)
            cylinder(h=pulley_width, r=base_r, center=true);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0,i*tooth_angle])
                    tooth3d(pulley_width);
            }
        }

        // Bore
        cylinder(h=hub_height+2, r=bore_d/2, center=true);
    }
}

pulley();