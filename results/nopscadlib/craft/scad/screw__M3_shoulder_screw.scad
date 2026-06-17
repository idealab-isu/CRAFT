// Screw: 4.0mm major diameter, 7.0mm head diameter, 2.4mm head height, 10.0mm overall length
// One connected solid, with visible threads and a Phillips drive.

shaft_diameter_mm = 4.0;   //[2.0:8.0:0.1]
head_diameter_mm  = 7.0;   //[3.5:14.0:0.1]
head_height_mm    = 2.4;   //[1.2:4.8:0.1]
overall_length_mm = 10.0;  //[5.0:20.0:0.5]

$fn = 96;

// Small overlap to guarantee watertight unions/differences
overlap = 0.05;

// Thread parameters (simple helical ridge approximation)
thread_pitch_mm   = 0.7;   // coarse-ish for M4 visual
thread_depth_mm   = 0.35;  // radial height of ridge
thread_starts     = 1;

// Phillips drive parameters
drive_depth_mm    = 1.2;
drive_width_mm    = 1.0;
drive_len_mm      = head_diameter_mm * 0.75;

// Derived
shaft_len_mm = overall_length_mm - head_height_mm;
major_r = shaft_diameter_mm/2;
minor_r = max(0.2, major_r - thread_depth_mm);

// --- Helpers ---
module phillips_drive_cut(head_r, head_h, depth, w, len) {
    // Cut two perpendicular slots, slightly tapered by using hull of two rectangles
    translate([0,0, head_h - depth + overlap])
    union() {
        for (a = [0, 90]) rotate([0,0,a]) {
            // Slot: long rectangle, centered
            translate([0,0,0])
                cube([len, w, depth + 2*overlap], center=true);
        }
    }
}

module threaded_shaft(major_r, minor_r, length, pitch, starts=1) {
    turns = length / pitch;

    union() {
        // Core cylinder (minor diameter)
        cylinder(h=length, r=minor_r, center=false);

        // Helical ridge(s)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
            linear_extrude(height=length, twist=turns*360, center=false, convexity=10, slices=max(40, ceil(turns*80)))
                translate([minor_r, 0, 0])
                    // Ridge cross-section (a small rectangle)
                    square([major_r - minor_r, pitch*0.45], center=false);
        }

        // Slight tip chamfer (helps look like a screw)
        translate([0,0,0])
            cylinder(h=min(0.8, length), r1=major_r*0.85, r2=major_r, center=false);
    }
}

module screw() {
    head_r = head_diameter_mm/2;

    // Place screw along +Z, bottom at z=0, top at z=overall_length_mm
    difference() {
        union() {
            // Threaded shaft from z=0 to z=shaft_len_mm
            threaded_shaft(major_r=major_r, minor_r=minor_r, length=shaft_len_mm, pitch=thread_pitch_mm, starts=thread_starts);

            // Head from z=shaft_len_mm to z=overall_length_mm
            translate([0,0,shaft_len_mm - overlap])
                cylinder(h=head_height_mm + overlap, r=head_r, center=false);

            // Small under-head fillet/neck (visual + ensures robust connection)
            translate([0,0,shaft_len_mm - 0.4])
                cylinder(h=0.4 + overlap, r1=major_r, r2=head_r*0.92, center=false);
        }

        // Phillips drive cut into top of head
        translate([0,0,shaft_len_mm])
            phillips_drive_cut(head_r=head_r, head_h=head_height_mm, depth=drive_depth_mm, w=drive_width_mm, len=drive_len_mm);
    }
}

screw();