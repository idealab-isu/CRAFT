// Threaded heat-set insert (approximation)
// Target: 25.0mm OD, 18.5mm long, for M10 screw

$fn = 160;

// Parameters
outer_diameter_mm = 25.0;
length_mm = 18.5;

screw_diameter_mm = 10.0;                 // M10 nominal major diameter
recommended_thread_pitch_mm = 1.5;        // M10 coarse is 1.5mm

bore_clearance_mm = 0.35;                 // clearance on major diameter for printable internal thread
chamfer_length_mm = 1.0;

knurl_count = 28;                         // external barbs/knurl count
knurl_depth_mm = 0.8;                     // radial protrusion
knurl_band_frac = 0.78;                   // portion of length covered by knurl band

overlap_mm = 0.6;

// Derived
outer_r = outer_diameter_mm/2;
L = length_mm;

thread_pitch = recommended_thread_pitch_mm;
thread_major_d = screw_diameter_mm + bore_clearance_mm; // internal thread major diameter
thread_major_r = thread_major_d/2;

// ISO metric thread approximations
thread_depth = 0.6134 * thread_pitch;     // radial depth (approx)
thread_minor_r = max(0.1, thread_major_r - thread_depth);

// External knurl band
knurl_band_h = L * knurl_band_frac;
knurl_band_z0 = -knurl_band_h/2;
knurl_band_z1 =  knurl_band_h/2;

// --- Helpers ---

module external_knurl() {
    // Adds outward barbs around the OD (connected solid via union with body)
    for (i = [0:knurl_count-1]) {
        rotate([0,0,i*360/knurl_count])
            translate([outer_r - overlap_mm, 0, 0])  // overlap into body to ensure connectivity
                cube([knurl_depth_mm + overlap_mm, 1.6, knurl_band_h], center=true);
    }
}

module body_with_chamfers_and_knurl() {
    union() {
        // Main cylinder
        cylinder(r=outer_r, h=L, center=true);

        // External knurl/barbs
        external_knurl();

        // Entry chamfers (both ends)
        translate([0,0, L/2 - chamfer_length_mm/2])
            cylinder(r1=outer_r, r2=outer_r - chamfer_length_mm, h=chamfer_length_mm, center=true);

        translate([0,0,-L/2 + chamfer_length_mm/2])
            cylinder(r1=outer_r - chamfer_length_mm, r2=outer_r, h=chamfer_length_mm, center=true);
    }
}

// Simple internal helical thread cutter (triangular profile) using linear_extrude twist
module internal_thread_cutter() {
    turns = (L + 2*overlap_mm) / thread_pitch;
    twist_deg = -360 * turns; // negative for right-hand internal thread when viewed from +Z

    // 2D triangular profile in X-Y plane, positioned at the major radius.
    // Extruded along Z with twist to form a helical ridge; subtracting it creates internal threads.
    linear_extrude(height=L + 2*overlap_mm, center=true, twist=twist_deg, slices=ceil(40*turns))
        translate([thread_major_r - thread_depth/2, 0, 0])
            polygon(points=[
                [ thread_depth/2, 0],
                [-thread_depth/2,  thread_pitch*0.28],
                [-thread_depth/2, -thread_pitch*0.28]
            ]);
}

module threaded_bore() {
    // Base bore to minor diameter + thread cutter to form internal thread
    union() {
        cylinder(r=thread_minor_r, h=L + 2*overlap_mm, center=true);
        internal_thread_cutter();
        // Lead-in chamfers for easier screw start
        translate([0,0, L/2 - chamfer_length_mm/2])
            cylinder(r1=thread_major_r, r2=thread_minor_r, h=chamfer_length_mm, center=true);
        translate([0,0,-L/2 + chamfer_length_mm/2])
            cylinder(r1=thread_minor_r, r2=thread_major_r, h=chamfer_length_mm, center=true);
    }
}

// Final model (one connected solid)
difference() {
    body_with_chamfers_and_knurl();
    threaded_bore();
}