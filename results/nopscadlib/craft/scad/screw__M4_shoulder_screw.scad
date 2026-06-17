// Screw: 5.0mm shaft diameter, 9.0mm head diameter, 2.4mm head height, 10.0mm total length

$fn = 128;

// Parameters (mm)
shaft_diameter_mm = 5.0;      // shaft major diameter
length_mm         = 10.0;     // total length (tip to top of head)
head_diameter_mm  = 9.0;      // head diameter
head_height_mm    = 2.4;      // head height

// Cosmetic thread parameters (simple ring threads)
threaded              = 1;     // 0/1
thread_pitch_mm       = 0.8;
thread_ring_height_mm = 0.25;
thread_radial_add_mm  = 0.25;
thread_start_clear_mm = 0.2;   // keep threads away from head underside
thread_end_clear_mm   = 0.2;   // keep threads away from tip
overlap_mm            = 0.25;  // overlap to ensure watertight union

module screw() {
    shaft_len = max(0, length_mm - head_height_mm);
    shaft_r   = shaft_diameter_mm/2;
    head_r    = head_diameter_mm/2;

    // Z=0 at tip, Z=length_mm at top of head
    union() {
        // Shaft (tip to underside of head)
        translate([0, 0, shaft_len/2])
            cylinder(h=shaft_len, r=shaft_r, center=true);

        // Head (underside to top), overlapped into shaft
        translate([0, 0, shaft_len + head_height_mm/2 - overlap_mm/2])
            cylinder(h=head_height_mm + overlap_mm, r=head_r, center=true);

        // Cosmetic thread rings along shaft (ensure they stay within shaft length)
        if (threaded && shaft_len > (thread_start_clear_mm + thread_end_clear_mm + thread_ring_height_mm)) {
            usable_len = shaft_len - thread_start_clear_mm - thread_end_clear_mm;
            ring_count = max(1, floor((usable_len - thread_ring_height_mm) / thread_pitch_mm) + 1);

            for (i = [0 : ring_count-1]) {
                zc = thread_end_clear_mm + thread_ring_height_mm/2 + i*thread_pitch_mm;

                // Clamp so rings never extend past the shaft ends
                zc_clamped = min(shaft_len - thread_start_clear_mm - thread_ring_height_mm/2, zc);

                translate([0, 0, zc_clamped])
                    cylinder(
                        h = thread_ring_height_mm + overlap_mm,
                        r = shaft_r + thread_radial_add_mm,
                        center = true
                    );
            }
        }
    }
}

screw();