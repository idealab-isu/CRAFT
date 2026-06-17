$fn = 96;

// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]   // M3 nominal
length_mm = 20.0;         //[10.0:40.0:0.5] // overall standoff length
outer_diameter_mm = 6.0;  //[3.5:12.0:0.5]  // "Nonemm" unspecified; keep parametric default

thread_pitch_mm = 0.5;    // M3 coarse pitch (visual)
thread_depth_mm = 0.25;   // visual thread depth
threaded_length_mm = 20.0;// internal threaded length (<= length_mm)
overlap_mm = 0.2;         // overlap for robust boolean ops
clearance_mm = 0.15;      // clearance for printable internal thread

// Helical INTERNAL thread cutter (visual approximation)
// Produces a solid to subtract from the body.
module internal_thread_cutter(d_nominal, pitch, length, depth, clearance=0) {
    turns = length / pitch;
    d_minor = d_nominal - 2*depth; // approximate minor diameter
    // Base bore ensures a continuous hole; helical wedge adds thread form.
    union() {
        cylinder(h=length + 2*overlap_mm, r=(d_minor/2) + clearance, center=false);

        // Helical wedge positioned near the nominal radius to carve thread grooves.
        linear_extrude(height=length + 2*overlap_mm,
                       twist=turns*360,
                       slices=max(ceil(turns*24), 60),
                       convexity=10)
            translate([d_nominal/2 - depth + clearance, 0, 0])
                polygon(points=[
                    [0, -pitch*0.30],
                    [depth + clearance, 0],
                    [0,  pitch*0.30]
                ]);
    }
}

// Standoff pillar: one connected solid with internal M3 thread
module standoff_pillar() {
    thread_len = min(threaded_length_mm, length_mm);

    difference() {
        // Main pillar body (single solid)
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        // Internal threaded hole, centered and fully contained within the body
        translate([0, 0, -thread_len/2])
            internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, thread_len,
                                   thread_depth_mm, clearance_mm);
    }
}

standoff_pillar();