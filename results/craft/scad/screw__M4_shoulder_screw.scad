// Screw only: 5.0mm shaft diameter, 9.0mm head diameter, head height 2.4mm, 10mm long (under-head length)
// One connected solid, with visible thread and drive recess.

// -------- Parameters (mm) --------
shaft_diameter_mm = 5.0;
overall_length_mm = 10.0;     // under-head length
head_diameter_mm  = 9.0;
head_height_mm    = 2.4;

// Thread (visual approximation)
pitch_mm          = 1.0;
thread_depth_mm   = 0.35;     // radial depth
threaded_length_mm = overall_length_mm; // fully threaded
$fn = 96;

eps = 0.02;
overlap = 0.2;

// -------- Helpers --------
module hex_socket(recess_af_mm, recess_depth_mm) {
    // Across-flats to circumscribed radius conversion for 6-sided polygon
    r_hex = recess_af_mm / (2 * cos(180/6));
    translate([0,0, head_height_mm - recess_depth_mm/2 + eps])
        cylinder(h=recess_depth_mm + 2*eps, r=r_hex, center=true, $fn=6);
}

module helical_thread(major_d, minor_d, length, pitch) {
    turns = length / pitch;
    // Triangular-ish thread profile placed at minor radius and swept helically
    r_minor = minor_d/2;
    prof = [
        [r_minor,                 -pitch*0.25],
        [r_minor + (major_d-minor_d)/2, 0],
        [r_minor,                  pitch*0.25]
    ];

    // Use linear_extrude with twist to create a helical ridge
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*24), 60), convexity=10)
        polygon(points=prof);
}

// -------- Screw --------
module screw() {
    major_d = shaft_diameter_mm + 2*thread_depth_mm;
    minor_d = shaft_diameter_mm;

    union() {
        // Head with slight chamfer
        difference() {
            union() {
                // Main head
                translate([0,0, overall_length_mm + head_height_mm/2 - overlap])
                    cylinder(d=head_diameter_mm, h=head_height_mm, center=true);

                // Small top chamfer (frustum)
                translate([0,0, overall_length_mm + head_height_mm - 0.35])
                    cylinder(d1=head_diameter_mm, d2=head_diameter_mm-0.8, h=0.7, center=true);
            }

            // Drive recess (hex socket)
            hex_socket(recess_af_mm=3.0, recess_depth_mm=1.6);
        }

        // Core shaft (minor diameter) under head
        translate([0,0, overall_length_mm/2 - overlap])
            cylinder(d=minor_d, h=overall_length_mm + 2*overlap, center=true);

        // Thread ridge (major diameter) along shaft
        // Start at z=0 (tip) and go up to z=threaded_length_mm
        translate([0,0, 0])
            helical_thread(major_d=major_d, minor_d=minor_d, length=threaded_length_mm, pitch=pitch_mm);

        // Tip chamfer
        translate([0,0, 0.35])
            cylinder(d1=minor_d-0.8, d2=minor_d, h=0.7, center=true);
    }
}

screw();