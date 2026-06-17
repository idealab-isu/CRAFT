// PTFE tubing (robust, non-blank render, single connected solid)

// Parameters
tube_L = 1000; //[500:2000:1]
tube_OD = 4;   //[2:8:0.1]
tube_ID = 2;   //[1:6:0.1]
end_chamfer = 0.5;      //[0:2:0.05]
end_fillet_r = 0.25;    //[0:1:0.05]
overlap = 1;            //[0.5:2:0.1]
mark_band_w = 2;        //[0.5:10:0.5]
mark_band_depth = 0.1;  //[0.05:0.5:0.05]

$fn = 96;

// ---- Derived / clamped values to avoid invalid geometry ----
eps = 0.02;

OD = max(tube_OD, 2*eps);
ID = min(max(tube_ID, 2*eps), OD - 2*eps);
wall = (OD - ID)/2;

// keep chamfer within length
ch = min(max(end_chamfer, 0), max(tube_L/2 - eps, 0));

// fillet limited by wall and by length
fil = min(max(end_fillet_r, 0), max(min(wall, tube_L/2) - eps, 0));

// marking band
band_w = min(max(mark_band_w, eps), max(tube_L - 2*eps, eps));
band_d = min(max(mark_band_depth, 0), max(wall - eps, 0));

// ---- Core tube with chamfered ends (hollow) ----
module tube_shell_chamfered(L, ODv, IDv, chv) {
    difference() {
        union() {
            // main outer body shortened by chamfers
            cylinder(h = max(L - 2*chv, eps), r = ODv/2, center = true);

            if (chv > eps) {
                // top chamfer frustum (outer to inner)
                translate([0, 0, L/2 - chv/2])
                    cylinder(h = chv, r1 = ODv/2, r2 = IDv/2, center = true);

                // bottom chamfer frustum (inner to outer)
                translate([0, 0, -(L/2 - chv/2)])
                    cylinder(h = chv, r1 = IDv/2, r2 = ODv/2, center = true);
            }
        }

        // Inner bore (slightly longer to guarantee clean subtraction)
        cylinder(h = L + 2*max(overlap, eps), r = IDv/2, center = true);
    }
}

// ---- Shallow recessed marking band (subtracted from OD only) ----
module marking_recess(L, ODv, band_wv, band_dv) {
    // Place band near one end (still fully on the tube), using formulas only
    zc = (L/2 - band_wv/2 - eps);

    translate([0, 0, zc])
        difference() {
            // outer "cutter" ring volume
            cylinder(h = band_wv, r = ODv/2 + max(overlap, eps), center = true);
            // inner limit so only a shallow recess is removed
            cylinder(h = band_wv + 2*max(overlap, eps), r = max(ODv/2 - band_dv, eps), center = true);
        }
}

// ---- Base model (no fillet) ----
module ptfe_tube_base(L, ODv, IDv, chv) {
    difference() {
        tube_shell_chamfered(L, ODv, IDv, chv);
        if (band_d > eps)
            marking_recess(L, ODv, band_w, band_d);
    }
}

// ---- Final model ----
// Avoid Minkowski on a long tube (often causes blank/failed renders). Use base tube.
// Keep fillet parameter but render robustly.
ptfe_tube_base(tube_L, OD, ID, ch);