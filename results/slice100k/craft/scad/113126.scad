// Thick C-shaped / U-channel bracket with offset lug/stop
// Bounding box target: 31.8 x 31.8 x 15.8 mm

$fn = 64;
eps = 0.02;

// Overall bounds (X, Y, Z)
L = 31.8;
W = 31.8;
T = 15.8;

// U-channel geometry (open to -Y, web remains on +Y, jaws are top/bottom in Z)
jaw_T = 2.9;           // thickness of top and bottom jaws (Z)
web_W = 6.0;           // thickness of side web that remains on +Y side (Y)

// Internal cavity (rectangular cutout that OPENS to -Y to form a true C/U channel)
cut_L = 24.0;          // cavity length (X)
relief_r = 1.2;        // optional internal corner relief

// Lug/stop (protrudes from -Y face, offset in X)
lug_L = 6.0;
lug_W = 3.0;           // protrusion outward (Y)
lug_T = 4.0;
lug_offset_from_edge = 2.0;

// Derived
inner_Z   = T - 2*jaw_T;                 // open height between jaws
cut_T_eff = inner_Z + 2*eps;             // ensure clean boolean
cut_L_eff = min(cut_L, L - 2*eps);       // keep within outer

// Cavity placement: open to -Y (flush with -Y outer face), leave web on +Y
cut_y_min    = -W/2 - eps;               // slightly beyond -Y face to guarantee opening
cut_y_max    =  W/2 - web_W;             // stop before +Y face to leave web
cut_y_center = (cut_y_min + cut_y_max)/2;
cut_y_size   = (cut_y_max - cut_y_min);

// Cavity placement in Z: remove only between jaws (leave top/bottom jaws intact)
cut_z_center = 0;                         // centered between jaws
cut_z_size   = inner_Z + 2*eps;

// Optional: through holes in the cavity floor/plate (as seen in top view)
hole_r = 1.6;
hole_x_off = 8.5;

module bracket_body() {
    difference() {
        // Outer block
        cube([L, W, T], center=true);

        // Main cavity: removes material between jaws AND opens to -Y, leaving +Y web
        translate([0, cut_y_center, cut_z_center])
            cube([cut_L_eff, cut_y_size, cut_z_size], center=true);

        // Internal corner reliefs near the web-side corners (kept subtle)
        for (sx = [-1, 1]) {
            translate([
                sx*(cut_L_eff/2 - relief_r),
                cut_y_max - relief_r,
                cut_z_center
            ])
                rotate([90, 0, 0])
                    cylinder(r=relief_r, h=cut_y_size + 2*eps, center=true);
        }

        // Two through holes (Z direction), positioned within the cavity region
        for (sx = [-1, 1]) {
            translate([sx*hole_x_off, 0, 0])
                cylinder(r=hole_r, h=T + 2*eps, center=true);
        }
    }
}

module lug_stop() {
    // Offset in X from -X edge
    lug_x = -L/2 + lug_offset_from_edge + lug_L/2;

    // Attach to -Y face with overlap into the body for a single solid
    overlap_y = 1.5; // 1–2mm overlap for robust union
    // Body -Y face is at -W/2. Lug extends outward by lug_W and overlaps inward by overlap_y.
    lug_y = -W/2 - lug_W/2 + overlap_y/2;

    // Place near top surface (still within overall T)
    lug_z = T/2 - lug_T/2;

    translate([lug_x, lug_y, lug_z])
        cube([lug_L, lug_W + overlap_y, lug_T], center=true);
}

union() {
    bracket_body();
    lug_stop();
}