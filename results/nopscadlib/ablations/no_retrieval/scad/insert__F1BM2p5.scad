// Threaded heat-set insert (visual model)
// Target: 5.8mm OD, 4.6mm length, for M2.5 screw

$fn = 128;

// Parameters
od = 5.8;                 // outer diameter (mm)
L  = 4.6;                 // body length (mm)

screw_clear_d = 2.5;      // visible internal hole for 2.5mm screw (mm)

chamfer = 0.3;            // lead-in chamfer height (mm)

flange_od  = 6.6;         // optional small flange OD (mm)
flange_thk = 0.6;         // flange thickness (mm)

knurl_depth = 0.25;       // radial protrusion (mm)
knurl_pitch = 0.6;        // axial spacing (mm)
knurl_band_margin = 0.55; // keep knurls away from ends (mm)

overlap = 0.2;            // boolean overlap (mm)

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Main solids
module body_cyl() {
    cylinder(h=L, r=od/2, center=true);
}

module flange() {
    // Flange attached to bottom face with slight overlap to ensure connectivity
    translate([0,0, -L/2 + flange_thk/2 - overlap/2])
        cylinder(h=flange_thk + overlap, r=flange_od/2, center=true);
}

module internal_bore() {
    // Through-hole for M2.5 screw visibility
    cylinder(h=L + flange_thk + 4*overlap, r=screw_clear_d/2, center=true);
}

module chamfer_cut(zsign=1) {
    // Conical cut at ends; zsign=+1 top, -1 bottom
    translate([0,0, zsign*(L/2 - chamfer/2)])
        cylinder(h=chamfer + 2*overlap, r1=od/2 + 0.01, r2=0, center=true);
}

module knurl_rings() {
    // Add outward rings (knurl-like) that remain connected to the body
    band_len = max(0, L - 2*knurl_band_margin);
    n = max(0, floor(band_len/knurl_pitch));
    if (n > 0) {
        for (i = [0:n-1]) {
            z0 = -L/2 + knurl_band_margin + (i + 0.5) * (band_len/n);
            translate([0,0,z0])
                cylinder(h=knurl_pitch*0.45, r=od/2 + knurl_depth, center=true);
        }
    }
}

module insert_solid() {
    union() {
        body_cyl();
        flange();
        knurl_rings();
    }
}

module insert_model() {
    difference() {
        // Outer connected solid
        insert_solid();

        // Internal hole
        internal_bore();

        // Lead-in chamfers (cuts)
        chamfer_cut(+1);
        chamfer_cut(-1);
    }
}

// Final
insert_model();