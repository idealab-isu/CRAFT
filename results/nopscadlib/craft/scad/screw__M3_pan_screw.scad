// Pan head screw: 3.0mm shaft dia, 5.4mm head dia, 2.0mm head height, 10mm overall length
$fn = 96;

// Parameters (mm)
shaft_diameter_mm = 3.0;
overall_length_mm = 10.0;
head_diameter_mm  = 5.4;
head_height_mm    = 2.0;

// Simple thread visual (kept subtle; still one connected solid)
thread_pitch_mm   = 0.6;   // visual only
thread_depth_mm   = 0.18;  // radial depth (visual only)
threaded_length_mm = overall_length_mm - head_height_mm;

// Small overlap to guarantee watertight unions
overlap_mm = 0.05;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Coordinate convention: Z=0 at underside of head; screw extends in -Z
module pan_head_screw() {
    difference() {
        union() {
            // Shaft (including threaded length)
            translate([0,0,-threaded_length_mm/2])
                cylinder(r=shaft_r, h=threaded_length_mm + overlap_mm, center=true);

            // Pan head (approximated with a short cylindrical skirt + domed top)
            // Skirt
            translate([0,0, head_height_mm*0.35/2])
                cylinder(r=head_r, h=head_height_mm*0.35 + overlap_mm, center=true);

            // Dome (spherical cap via scaled sphere, intersected to head height)
            intersection() {
                translate([0,0, head_height_mm*0.35])
                    scale([1,1,0.55])
                        sphere(r=head_r);
                translate([0,0, head_height_mm/2])
                    cylinder(r=head_r + 0.01, h=head_height_mm + overlap_mm, center=true);
            }

            // Simple helical-ish thread impression using stacked rings (still one solid)
            // Rings are placed along the shaft and overlap it.
            ring_h = thread_pitch_mm*0.45;
            n = max(2, floor(threaded_length_mm/thread_pitch_mm) + 1);
            for (i = [0:n-1]) {
                z = -threaded_length_mm + (i/(n-1))*threaded_length_mm;
                translate([0,0, z + ring_h/2])
                    cylinder(r=shaft_r + thread_depth_mm, h=ring_h, center=true);
            }
        }

        // Phillips-like cross recess (subtracted) in head
        recess_depth = head_height_mm*0.55;
        recess_r = head_r*0.55;
        slot_w = 0.8;

        translate([0,0, head_height_mm - recess_depth/2])
            union() {
                cylinder(r=recess_r, h=recess_depth + overlap_mm, center=true);
                cube([2*recess_r, slot_w, recess_depth + overlap_mm], center=true);
                cube([slot_w, 2*recess_r, recess_depth + overlap_mm], center=true);
            }
    }
}

pan_head_screw();