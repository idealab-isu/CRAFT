// Standoff pillar: 6.0mm long body with M3 (3.0mm) internal thread (modeled) and hex exterior
// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]   // nominal major diameter (M3 = 3.0)
length_mm = 6.0;         //[3.0:12.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]   // across flats for hex body
pitch_mm = 0.5;          //[0.35:1.0:0.05]  // M3 coarse = 0.5
thread_depth_mm = 0.25;  //[0.05:0.6:0.05]  // radial depth of modeled thread
overlap_mm = 0.2;        //[0.05:1.0:0.05]

$fn = 128;

// 2D hex profile (across flats = af)
module hex2d(af) {
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

// Simple internal thread approximation: subtract a helical "ridge" from the bore
module internal_thread_cut(minor_d, pitch, depth, h) {
    // minor_d is the base bore diameter before threading
    // depth is radial thread depth (approx)
    turns = h / pitch;

    // Helical ridge cross-section (2D) placed at bore radius, then twisted along Z
    // This creates a visible thread impression without requiring exact ISO profile.
    linear_extrude(height=h + 2*overlap_mm, twist=turns*360, slices=max(ceil(turns*48), 48), center=true)
        translate([minor_d/2, 0, 0])
            square([depth, pitch*0.55], center=true);
}

module standoff_pillar() {
    // Derived diameters for internal thread approximation
    // Use a slightly smaller minor diameter so the helical cut leaves a thread-like surface.
    minor_d = max(thread_diameter_mm - 2*thread_depth_mm, thread_diameter_mm*0.75);

    difference() {
        // Outer body: hex standoff
        linear_extrude(height=length_mm, center=true)
            hex2d(outer_diameter_mm);

        // Base bore (through-hole)
        cylinder(h=length_mm + 2*overlap_mm, r=minor_d/2, center=true);

        // Thread impression cut (connected subtraction, same center)
        internal_thread_cut(minor_d=minor_d, pitch=pitch_mm, depth=thread_depth_mm, h=length_mm);
    }
}

standoff_pillar();