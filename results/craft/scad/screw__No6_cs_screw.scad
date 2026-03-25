$fn = 128;

// Target dimensions (mm)
shaft_diameter_mm = 3.5;
head_diameter_mm  = 7.0;
length_mm         = 10.0;

// Head + drive (simple pan head + slot)
head_height_mm    = 2.4;
drive_width_mm    = 1.2;   // slot width
drive_depth_mm    = 0.7;   // slot depth

// Threads (visual)
thread_pitch_mm   = 0.8;
thread_depth_mm   = 0.25;  // radial depth of thread (major radius = shaft_r + depth)
tip_length_mm     = 1.2;   // pointed/tapered tip length

// Robustness
overlap_mm        = 0.15;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;
thread_r = shaft_r + thread_depth_mm;

shank_length_mm   = length_mm - head_height_mm;
thread_length_mm  = max(0, shank_length_mm - tip_length_mm);

// Z layout (bottom at z=0, top of head at z=length)
z_head_bottom = length_mm - head_height_mm;
z_head_top    = length_mm;

// Helical ridge (adds material) using twisted extrusion of a small triangular profile
module helical_thread(r_base, depth, pitch, len) {
    turns = len / pitch;
    linear_extrude(
        height = len,
        twist = turns * 360,
        slices = max(ceil(turns * 60), 80),
        convexity = 10
    )
        translate([r_base, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module screw() {
    difference() {
        union() {
            // Core shank (minor diameter) up to underside of head
            cylinder(r=shaft_r, h=shank_length_mm, center=false);

            // Pointed/tapered tip (connected)
            // Base at z=0, tip at z=tip_length_mm
            cylinder(r1=thread_r, r2=0.05, h=tip_length_mm, center=false);

            // Thread ridge along threaded portion (connected, overlaps into core)
            if (thread_length_mm > 0)
                translate([0, 0, tip_length_mm - overlap_mm])
                    helical_thread(
                        r_base = shaft_r - thread_depth_mm*0.05,
                        depth  = thread_depth_mm,
                        pitch  = thread_pitch_mm,
                        len    = thread_length_mm + overlap_mm
                    );

            // Head (connected to shank with overlap)
            translate([0, 0, z_head_bottom - overlap_mm])
                cylinder(r=head_r, h=head_height_mm + overlap_mm, center=false);
        }

        // Slotted drive cut into head from the top
        translate([0, 0, z_head_top - drive_depth_mm/2])
            cube([head_diameter_mm*0.92, drive_width_mm, drive_depth_mm + overlap_mm], center=true);
    }
}

color("DimGray") screw();