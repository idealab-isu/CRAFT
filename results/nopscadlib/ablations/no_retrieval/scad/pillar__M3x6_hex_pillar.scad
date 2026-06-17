// Standoff pillar with internal M3x0.5 thread, 6mm long
// Prompt diameter is unclear ("Nonemm") -> keep parameterized; default 6mm OD.

$fn = 128;

// Parameters
length = 6.0;                       //[3.0:12.0:0.1]
outer_diameter = 6.0;               //[4.0:12.0:0.1]

thread_nominal_diameter = 3.0;      //[2.0:6.0:0.1]  // M3
thread_pitch = 0.5;                 //[0.25:1.0:0.05]
thread_length = 6.0;                //[2.0:12.0:0.1]

clearance = 0.15;                   //[0.0:0.4:0.01] // printing clearance for internal thread
lead_in = 0.6;                      //[0.2:1.5:0.1]
chamfer_radial = 0.35;              //[0.1:1.0:0.05]
overlap = 0.25;                     //[0.05:0.8:0.05]

// ISO metric 60° thread approximation
thread_depth = 0.6134 * thread_pitch; // radial depth approximation
minor_d = thread_nominal_diameter - 2*thread_depth + 2*clearance; // internal minor diameter
major_d = thread_nominal_diameter + 2*clearance;                  // internal major diameter (at crests)

minor_r = max(0.2, minor_d/2);
major_r = max(minor_r + 0.05, major_d/2);

// Ensure the hole fits inside the body
outer_r = outer_diameter/2;
assert(outer_r > major_r + 0.4, "Outer diameter too small for M3 internal thread with given clearance.");

// Body (pillar)
module standoff_body() {
    cylinder(h=length, r=outer_r, center=true);
}

// Helical internal thread cutter (subtract from body)
// Use a radial "wedge" profile so the helical surface is clearly visible.
module internal_thread_cutter(h, pitch, r_minor, r_major) {
    turns = h / pitch;
    twist_deg = -360 * turns; // negative for internal thread handedness

    // Angular thickness of the wedge (in degrees) controls visibility/detail
    wedge_deg = 22; // wider than a thin triangle so it shows in renders
    slices_n = max(ceil(turns * 80), 160);

    linear_extrude(height=h + overlap, twist=twist_deg, slices=slices_n, center=true, convexity=10)
        difference() {
            // Outer sector at r_major
            rotate(-wedge_deg/2)
                intersection() {
                    circle(r=r_major);
                    polygon(points=[
                        [0,0],
                        [r_major*2, 0],
                        [r_major*2*cos(wedge_deg), r_major*2*sin(wedge_deg)]
                    ]);
                }
            // Remove inner sector up to r_minor to make a ring-sector (thread depth)
            rotate(-wedge_deg/2)
                intersection() {
                    circle(r=r_minor);
                    polygon(points=[
                        [0,0],
                        [r_major*2, 0],
                        [r_major*2*cos(wedge_deg), r_major*2*sin(wedge_deg)]
                    ]);
                }
        }
}

// Core bore to guarantee a through-hole at minor diameter
module core_bore(h) {
    cylinder(h=h + overlap, r=minor_r, center=true);
}

// Lead-in chamfers at both ends
module lead_in_chamfers() {
    translate([0, 0,  length/2 - lead_in/2])
        cylinder(h=lead_in + overlap, r1=major_r + chamfer_radial, r2=major_r, center=true);
    translate([0, 0, -length/2 + lead_in/2])
        cylinder(h=lead_in + overlap, r1=major_r, r2=major_r + chamfer_radial, center=true);
}

// Final model (one connected solid)
difference() {
    standoff_body();

    // Center the cutters so they span the full pillar length
    union() {
        core_bore(thread_length);
        internal_thread_cutter(thread_length, thread_pitch, minor_r, major_r);
        lead_in_chamfers();
    }
}