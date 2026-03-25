// Standoff pillar (female-female) with internal M3 thread geometry
// Spec: 3.0mm thread, 13.0mm long, outer diameter = outer_diameter_mm (set as needed)

// Parameters
thread_diameter_mm = 3.0;   //[1.5:6.0:0.1]
length_mm          = 13.0;  //[6.5:26.0:0.5]
outer_diameter_mm  = 6.0;   //[3.5:12.0:0.5]

// M3 coarse pitch default
thread_pitch_mm    = 0.5;   //[0.25:1.0:0.05]

// Fit/visual tweaks
clearance_mm = 0.15;        // radial clearance for printed internal thread
chamfer_mm   = 0.4;         // small end chamfer
overlap_mm   = 0.05;        // boolean overlap to ensure watertight

$fn = 128;

// Derived
outer_r = outer_diameter_mm/2;

// ISO metric thread approximations (good visual/printable internal thread)
major_d = thread_diameter_mm + 2*clearance_mm;     // internal thread major diameter (hole crest)
major_r = major_d/2;

thread_h = 0.61343 * thread_pitch_mm;              // ISO 60° thread height (approx)
minor_r  = max(0.01, major_r - thread_h);          // internal thread minor radius (root)

// Ensure wall thickness remains positive
assert(outer_r > major_r + 0.6, "Outer diameter too small for M3 internal thread; increase outer_diameter_mm.");

// 2D profile for internal thread cutting tool (a small triangle near the hole wall)
module internal_thread_cut(h, pitch, major_r, minor_r) {
    turns = h / pitch;
    slices = max(ceil(turns * 40), 80);

    // Triangle spans from major_r (crest) to minor_r (root)
    // Positioned so it cuts into the cylindrical hole wall.
    linear_extrude(height=h, twist=-360*turns, slices=slices, convexity=10)
        polygon(points=[
            [minor_r, -pitch/4],
            [major_r,  0],
            [minor_r,  pitch/4]
        ]);
}

module standoff_pillar() {
    difference() {
        // Outer body (one connected solid)
        union() {
            cylinder(h=length_mm, r=outer_r);

            // End chamfers (connected; formula-based placement)
            if (chamfer_mm > 0) {
                // Bottom chamfer
                cylinder(h=chamfer_mm + overlap_mm, r1=outer_r - chamfer_mm, r2=outer_r);

                // Top chamfer
                translate([0, 0, length_mm - chamfer_mm - overlap_mm])
                    cylinder(h=chamfer_mm + overlap_mm, r1=outer_r, r2=outer_r - chamfer_mm);
            }
        }

        // Base cylindrical hole at thread major diameter (so thread crests are not blocked)
        translate([0, 0, -overlap_mm])
            cylinder(h=length_mm + 2*overlap_mm, r=major_r);

        // Helical internal thread cut (creates real thread geometry)
        translate([0, 0, -overlap_mm])
            internal_thread_cut(
                h = length_mm + 2*overlap_mm,
                pitch = thread_pitch_mm,
                major_r = major_r,
                minor_r = minor_r
            );
    }
}

standoff_pillar();