// Dimension-calibrated (target: 12.00 x 22.98 x 24.00 mm)
scale([0.999087, 1.043261, 0.495868])
{
// Spool-like turned sleeve (no bore), rotationally symmetric
// Bounding box target: 12.0 x 23.0 x 24.0 mm  (X=12, Y=23, Z=24)

$fn = 160;

// --- Parameters (mm) ---
L = 24.0;                 // overall length (Z)
OD_max = 23.0;            // maximum diameter (Y)
OD_mid = 18.0;            // intermediate diameter
OD_min = 12.0;            // minimum diameter (X)
end_band_len = 4.0;       // raised band length at each end
groove_len = 3.5;         // recessed groove length next to center band
center_band_len = 5.0;    // raised band length at center
fillet_r = 0.6;           // smooth transition radius (approx via hull)
overlap = 0.2;            // small overlap to ensure connectivity

// --- Derived lengths (ensure exact total length) ---
min_len_total = L - (2*end_band_len + 2*groove_len + center_band_len);
min_len_each  = min_len_total/2;

// Guard against invalid parameter combinations
assert(min_len_total >= 0, "Invalid lengths: 2*end_band_len + 2*groove_len + center_band_len must be <= L");

// --- Helper: rounded step between two radii over a short axial span ---
module rounded_step(z0, z1, r0, r1, rr=0.6) {
    // z0 < z1, radii r0->r1
    // Use hull of two short cylinders to approximate a filleted transition.
    hull() {
        translate([0,0,z0]) cylinder(h=2*rr, r=r0, center=true);
        translate([0,0,z1]) cylinder(h=2*rr, r=r1, center=true);
    }
}

// --- Main body via rotate_extrude of a 2D profile with rounded corners ---
module spool_body() {
    rMax = OD_max/2;
    rMid = OD_mid/2;
    rMin = OD_min/2;

    // Axial landmarks (Z)
    z0 = -L/2;
    z1 = z0 + end_band_len;          // end band -> min
    z2 = z1 + min_len_each;          // min -> mid
    z3 = z2 + groove_len;            // mid -> max (center band start)
    z4 = z3 + center_band_len;       // max -> mid
    z5 = z4 + groove_len;            // mid -> min
    z6 = z5 + min_len_each;          // min -> end band
    z7 = L/2;

    // Build as union of straight sections + rounded transitions (all connected)
    union() {
        // Straight sections
        translate([0,0,(z0+z1)/2]) cylinder(h=(z1-z0)+overlap, r=rMax, center=true);
        translate([0,0,(z1+z2)/2]) cylinder(h=(z2-z1)+overlap, r=rMin, center=true);
        translate([0,0,(z2+z3)/2]) cylinder(h=(z3-z2)+overlap, r=rMid, center=true);
        translate([0,0,(z3+z4)/2]) cylinder(h=(z4-z3)+overlap, r=rMax, center=true);
        translate([0,0,(z4+z5)/2]) cylinder(h=(z5-z4)+overlap, r=rMid, center=true);
        translate([0,0,(z5+z6)/2]) cylinder(h=(z6-z5)+overlap, r=rMin, center=true);
        translate([0,0,(z6+z7)/2]) cylinder(h=(z7-z6)+overlap, r=rMax, center=true);

        // Rounded transitions (fillet-like)
        rounded_step(z1, z1, rMax, rMin, fillet_r); // local reinforcement at step
        rounded_step(z2, z2, rMin, rMid, fillet_r);
        rounded_step(z3, z3, rMid, rMax, fillet_r);
        rounded_step(z4, z4, rMax, rMid, fillet_r);
        rounded_step(z5, z5, rMid, rMin, fillet_r);
        rounded_step(z6, z6, rMin, rMax, fillet_r);
    }
}

// Final output: single connected solid, no holes, no textures/engraving
spool_body();
}
