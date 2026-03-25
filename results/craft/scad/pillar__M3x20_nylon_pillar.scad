// Standoff pillar: M3 internal thread, 20mm long, 8mm OD (single connected solid)

// Parameters
thread_diameter = 3.0;      //[1.5:6.0:0.1]  // nominal thread size (M3)
overall_length  = 20.0;     //[10.0:40.0:0.5]
outer_diameter  = 8.0;      //[4.0:16.0:0.5]
bore_extra      = 0.2;      //[0.0:0.6:0.05] // clearance for internal thread
bore_height_extra = 0.6;    //[0.0:2.0:0.1]  // small overcut to ensure clean through-hole

// Thread approximation parameters (ISO metric coarse defaults)
thread_pitch = 0.5;         // M3 coarse pitch
thread_depth = 0.30;        // visual/printable thread depth (approx)
thread_fn    = 80;          // smoothness for cylinders
twist_steps_per_turn = 24;  // resolution of helix

// Internal (female) thread cutter using a helical triangular profile
module internal_thread_cutter(d_nom, pitch, length, depth, clearance=0.0) {
    // Minor diameter approximation for ISO metric internal thread:
    // D1 ≈ D - 1.08253 * P
    d_minor = d_nom - 1.08253 * pitch;

    // Cutter radii (add clearance and depth so subtraction leaves visible thread)
    r_minor = (d_minor + clearance)/2;
    r_major = (d_nom   + clearance)/2;

    // Ensure the cutter actually forms a thread by extending slightly beyond ends
    extra = pitch; // one pitch extra each end
    h = length + 2*extra;

    // Helical ridge to subtract (creates grooves in the hole)
    // Profile is a small triangle spanning from minor to major radius.
    translate([0,0,-h/2])
    linear_extrude(height=h,
                  twist=360*h/pitch,
                  slices=ceil((h/pitch)*twist_steps_per_turn),
                  convexity=10)
        polygon(points=[
            [r_minor, -pitch*0.22],
            [r_major + depth, 0],
            [r_minor,  pitch*0.22]
        ]);
}

// Standoff body with internal thread
module standoff_pillar() {
    difference() {
        // Outer body
        cylinder(h=overall_length, r=outer_diameter/2, center=true, $fn=thread_fn);

        // Base through-hole (minor diameter) to guarantee a clean bore
        // Use formula-based height with slight overcut
        cylinder(h=overall_length + bore_height_extra,
                 r=(thread_diameter - 1.08253*thread_pitch + bore_extra)/2,
                 center=true, $fn=thread_fn);

        // Thread grooves (helical cutter)
        internal_thread_cutter(thread_diameter, thread_pitch,
                               overall_length, thread_depth,
                               clearance=bore_extra);
    }
}

standoff_pillar();