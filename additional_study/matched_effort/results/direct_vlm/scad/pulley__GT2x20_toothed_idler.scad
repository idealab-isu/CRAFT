$fn = 220;

// Timing pulley
// Requirements: 20 teeth, 12.22mm pitch diameter

teeth = 20;
pitch_d = 12.22;                 // mm
pitch_r = pitch_d/2;

pulley_width = 10;               // mm (toothed section width)
bore_d = 5;                      // mm

// Tooth geometry (simple, clearly countable)
tooth_height = 1.25;             // mm above pitch circle
tooth_root_clear = 0.75;         // mm below pitch circle
tooth_arc_frac = 0.42;           // fraction of tooth pitch occupied by tooth at pitch circle
tooth_round = 0.18;              // mm rounding for tooth corners

// Flanges
flange_thickness = 1.0;          // mm
flange_overhang = 1.0;           // mm beyond tooth tip radius

// Connectivity overlap
eps = 0.15;                      // mm

// Derived radii
root_r = max(0.2, pitch_r - tooth_root_clear);
tip_r  = pitch_r + tooth_height;

module tooth2d() {
    // Tooth centered on +X axis; rotated around origin.
    // Width computed from pitch at pitch radius.
    pitch = 2*PI*pitch_r / teeth;          // linear pitch along pitch circle
    tooth_w = pitch * tooth_arc_frac;      // linear tooth width at pitch circle
    ang = tooth_w / pitch_r;               // radians

    // Chord width at pitch radius
    chord = 2*pitch_r*sin(ang/2);

    // Radial length from root to tip, with overlap into root cylinder
    radial_len = (tip_r - root_r) + 2*eps;

    // Place tooth so it overlaps into root cylinder by eps
    inner_x = root_r - eps;
    center_x = inner_x + radial_len/2;

    translate([center_x, 0])
        offset(r=tooth_round)
            square([radial_len, max(0.01, chord - 2*tooth_round)], center=true);
}

module pulley() {
    flange_r = tip_r + flange_overhang;

    difference() {
        union() {
            // Root cylinder (tooth valleys)
            cylinder(h=pulley_width, r=root_r, center=true);

            // Teeth (radial array, protruding outward, overlapping into root cylinder)
            for (i = [0:teeth-1])
                rotate([0,0,i*360/teeth])
                    linear_extrude(height=pulley_width, center=true, convexity=10)
                        tooth2d();

            // Flanges: positioned to touch/overlap the toothed body ends (no floating)
            if (flange_thickness > 0) {
                for (z = [
                    -(pulley_width/2 + flange_thickness/2 - eps),
                     (pulley_width/2 + flange_thickness/2 - eps)
                ])
                    translate([0,0,z])
                        cylinder(h=flange_thickness, r=flange_r, center=true);
            }
        }

        // Bore through entire part (including flanges)
        cylinder(
            h = pulley_width + 2*flange_thickness + 2,
            r = bore_d/2,
            center = true
        );
    }
}

pulley();