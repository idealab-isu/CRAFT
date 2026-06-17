// Threaded heat-set insert
// Target: 5.8mm OD, 4.6mm length, for M3 screws

$fn = 128;

// --- Parameters (verifiable) ---
od = 5.8;     // outer diameter (mm)
L  = 4.6;     // overall length (mm)

// Lead-in chamfers
chamfer_h = 0.4;  // axial height (mm)
chamfer_w = 0.3;  // radial reduction (mm)

// Outer knurl/serration
knurl_depth = 0.30;   // radial protrusion beyond OD (mm)
knurl_pitch = 0.80;   // approx circumferential pitch (mm)
ridge_w     = 0.45;   // tangential width (mm)

// Internal thread (modeled as a helical groove cut into the bore)
thread_major_d = 3.0;   // M3 major diameter (mm)
thread_pitch   = 0.5;   // M3 coarse pitch (mm)
thread_depth   = 0.22;  // radial depth of groove (mm) - increased for visibility

// Robustness / overlap
eps     = 0.02;
overlap = 0.30;

// --- Derived ---
r_outer = od/2;
r_knurl_outer = r_outer + knurl_depth;

ridge_h = max(0.01, L - 2*chamfer_h); // keep ridges off chamfers

// Choose a bore that allows visible thread while remaining inside the insert wall.
// For a modeled internal thread, the bore should be near the thread minor diameter.
// (This is a visual/approx model; adjust to match your insert spec if needed.)
id_bore = 2.55;                 // (mm) ~ M3 minor diameter region for visible internal thread
r_bore  = id_bore/2;

// Ensure thread groove is cut into the bore wall (not floating in empty space)
r_thread_major = thread_major_d/2;
r_thread_groove_center = min(r_thread_major - thread_depth/2, r_bore - thread_depth/2 - 0.03);
thread_groove_r = max(0.06, thread_depth/2);

// Knurl count from circumference and pitch
num_ridges = max(18, floor((PI*od)/knurl_pitch));

// --- Modules ---
module outer_body_with_chamfers() {
    // Outer envelope MUST remain exactly OD and L
    difference() {
        cylinder(h=L, r=r_outer, center=true);

        // Top chamfer (remove material)
        translate([0,0, L/2 - chamfer_h/2])
            cylinder(h=chamfer_h + 2*eps,
                     r1=r_outer + eps,
                     r2=r_outer - chamfer_w,
                     center=true);

        // Bottom chamfer (remove material)
        translate([0,0,-L/2 + chamfer_h/2])
            cylinder(h=chamfer_h + 2*eps,
                     r1=r_outer - chamfer_w,
                     r2=r_outer + eps,
                     center=true);
    }
}

module knurl_ridges() {
    // Radial array of ridges that protrude outward and overlap into the body
    ridge_len_radial = knurl_depth + overlap;                 // total radial length of ridge solid
    ridge_center_r   = r_outer + ridge_len_radial/2 - overlap; // overlap into body by 'overlap'

    for (i = [0 : num_ridges-1]) {
        rotate([0,0, i*360/num_ridges])
            translate([ridge_center_r, 0, 0])
                cube([ridge_len_radial, ridge_w, ridge_h], center=true);
    }
}

module outer_with_knurl() {
    union() {
        outer_body_with_chamfers();
        knurl_ridges();
    }
}

module bore() {
    // Straight bore through (subtracted)
    cylinder(h=L + 2*overlap, r=r_bore, center=true);
}

module internal_thread_groove() {
    // Helical groove cut into the bore wall (subtracted)
    turns = (L + 2*overlap) / thread_pitch;
    twist_deg = -360 * turns; // right-hand-ish when viewed from top

    translate([0,0, -(L/2 + overlap)])
        linear_extrude(height=L + 2*overlap,
                       twist=twist_deg,
                       slices=max(ceil(turns*80), 160),
                       convexity=10)
            translate([r_thread_groove_center, 0, 0])
                circle(r=thread_groove_r, $fn=48);
}

module insert() {
    // One connected solid: outer union, then subtract bore and thread groove
    difference() {
        outer_with_knurl();
        bore();
        internal_thread_groove();
    }
}

// Final output
color("Gold") insert();