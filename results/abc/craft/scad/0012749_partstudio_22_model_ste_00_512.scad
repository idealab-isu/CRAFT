// Dimension-calibrated (target: 0.05 x 0.05 x 0.01 mm)
scale([0.000520, 0.000960, 0.006500])
{
// Thin rectangular plate with shallow triangular corner recesses on BOTH large faces.
// Units: mm

// Parameters
plate_L = 100;          // length (X)
plate_W = 50;           // width  (Y)
plate_T = 2;            // thickness (Z)

corner_cut_leg   = 6;   // triangle leg size along edges
corner_cut_depth = 0.6; // recess depth into each face

eps = 0.02;             // small overlap for robust boolean ops

// --- Helpers ---
module plate_body() {
    cube([plate_L, plate_W, plate_T], center=true);
}

// Triangular prism for subtracting a corner recess.
// Base triangle is in XY with right angle at origin, legs along +X and +Y.
// Extrudes along +Z.
module corner_relief_prism(depth) {
    linear_extrude(height=depth, center=false)
        polygon(points=[[0,0],[corner_cut_leg,0],[0,corner_cut_leg]]);
}

// Place a corner relief at corner (sx,sy) on face (sz).
// sx,sy,sz are +/-1.
module place_corner_relief(sx, sy, sz) {
    // Corner location on the plate
    x0 = sx * plate_L/2;
    y0 = sy * plate_W/2;

    // Rotation so triangle points inward from that corner
    rot = (sx > 0 && sy > 0) ? 180 :
          (sx < 0 && sy > 0) ? 270 :
          (sx < 0 && sy < 0) ? 0   : 90;

    // Z placement: cut into top or bottom face
    z0 = (sz > 0) ? (plate_T/2 - corner_cut_depth - eps) : (-plate_T/2 - eps);

    translate([x0, y0, z0])
        rotate([0, 0, rot])
            corner_relief_prism(corner_cut_depth + 2*eps);
}

module all_corner_reliefs() {
    union() {
        for (sx = [-1, 1])
            for (sy = [-1, 1]) {
                place_corner_relief(sx, sy, +1); // top face
                place_corner_relief(sx, sy, -1); // bottom face
            }
    }
}

// --- Final model ---
difference() {
    plate_body();
    all_corner_reliefs();
}
}
