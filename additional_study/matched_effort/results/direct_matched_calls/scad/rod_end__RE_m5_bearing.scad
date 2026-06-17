$fn=96;

// Approximate model of a uxcell-style M5x0.8 right-hand male rod end (self-lubricating).
// Not a threaded model; thread represented as a smooth shank with a small lead-in chamfer.

module rod_end_m5(
    shank_d=5.0,
    shank_len=22.0,
    head_od=12.0,
    head_thk=6.0,
    eye_id=5.2,
    eye_boss_od=8.0,
    eye_boss_thk=6.0,
    neck_d=6.0,
    neck_len=3.0,
    wrench_flat=8.0,
    wrench_thk=3.0,
    chamfer=0.6
){
    // Coordinate system:
    // Shank extends in -Z, head centered around Z=0..head_thk, eye through X.
    union(){
        // Head body (outer)
        difference(){
            // Outer head: cylinder + small neck transition
            union(){
                // Main head
                translate([0,0,0])
                    cylinder(d=head_od, h=head_thk);

                // Neck to shank
                translate([0,0,-neck_len])
                    cylinder(d=neck_d, h=neck_len);

                // Shank (smooth, representing threaded portion)
                translate([0,0,-neck_len-shank_len])
                    cylinder(d=shank_d, h=shank_len);

                // Lead-in chamfer at shank end
                translate([0,0,-neck_len-shank_len])
                    cylinder(d1=shank_d-2*chamfer, d2=shank_d, h=chamfer);

                // Small fillet-like cone from neck to head
                translate([0,0,0])
                    cylinder(d1=neck_d, d2=head_od, h=1.2);
            }

            // Eye through-hole (ball bore)
            translate([0,0,head_thk/2])
                rotate([0,90,0])
                    cylinder(d=eye_id, h=head_od+2, center=true);

            // Side relief to suggest spherical seat (subtle)
            translate([0,0,head_thk/2])
                sphere(d=eye_boss_od);

            // Wrench flats on neck (two opposing cuts)
            translate([0,0,-neck_len/2])
                for (a=[0,90])
                    rotate([0,0,a])
                        translate([wrench_flat/2,0,0])
                            cube([head_od, head_od, wrench_thk], center=true);
        }

        // Add outer boss around eye (slightly thicker ring)
        difference(){
            translate([0,0,(head_thk-eye_boss_thk)/2])
                cylinder(d=eye_boss_od, h=eye_boss_thk);

            translate([0,0,head_thk/2])
                rotate([0,90,0])
                    cylinder(d=eye_id, h=eye_boss_od+2, center=true);
        }
    }
}

rod_end_m5();