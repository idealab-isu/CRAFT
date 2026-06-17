$fn=96;

// Approximate model of a uxcell M5x0.8 right-hand male rod end (self-lubricating joint)
// Not a thread-accurate model; includes a simplified threaded shank and rod-end head with through bore.

module rod_end_m5(
    shank_thread_d = 5.0,      // nominal M5 major diameter
    pitch = 0.8,               // M5x0.8
    shank_len = 22.0,          // threaded length (approx)
    shank_relief_len = 2.0,    // small unthreaded relief near head
    head_outer_d = 16.0,       // head OD (approx)
    head_thickness = 8.0,      // head thickness (approx)
    bore_d = 5.2,              // ball/bearing bore (approx for M5 bolt)
    ball_d = 10.0,             // internal ball OD (approx)
    neck_d = 7.5,              // neck diameter between head and shank
    neck_len = 4.0,            // neck length
    wrench_flat = 8.0,         // flats across (approx)
    wrench_thickness = 3.0     // thickness of wrench flats section
){
    // Coordinate system:
    // Shank along +Z, head centered at origin with thickness along Z.
    // Bore through head along X.

    module simplified_thread(d, L, pitch, depth=0.35){
        // Visual helical ridge approximation (not printable/functional thread)
        // Base cylinder + helical triangular ridge
        union(){
            cylinder(d=d-0.2, h=L);
            linear_extrude(height=L, twist=360*L/pitch, slices=max(20, ceil(L/pitch)*24))
                translate([d/2 - depth, 0, 0])
                    polygon(points=[
                        [0, -pitch*0.18],
                        [depth, 0],
                        [0, pitch*0.18]
                    ]);
        }
    }

    module wrench_flats_section(d, flats, h){
        // Cylinder with two opposing flats
        difference(){
            cylinder(d=d, h=h);
            // Cut flats
            for (s=[-1,1]){
                translate([s*(flats/2), 0, h/2])
                    rotate([0,90,0])
                        cube([h+0.2, d+2, d+2], center=true);
            }
        }
    }

    // Head with bore and ball seat approximation
    module head(){
        difference(){
            union(){
                // Outer head
                translate([0,0,-head_thickness/2])
                    cylinder(d=head_outer_d, h=head_thickness);

                // Neck + wrench flats + shank relief
                translate([0,0,head_thickness/2])
                    cylinder(d=neck_d, h=neck_len);

                translate([0,0,head_thickness/2 + neck_len])
                    wrench_flats_section(d=neck_d+1.5, flats=wrench_flat, h=wrench_thickness);

                translate([0,0,head_thickness/2 + neck_len + wrench_thickness])
                    cylinder(d=shank_thread_d, h=shank_relief_len);
            }

            // Through bore along X
            rotate([0,90,0])
                cylinder(d=bore_d, h=head_outer_d+4, center=true);

            // Ball cavity approximation (spherical)
            sphere(d=ball_d);

            // Side relief to suggest race opening (subtle)
            translate([0,0,0])
                rotate([0,90,0])
                    cylinder(d=ball_d*0.72, h=head_outer_d+6, center=true);
        }
    }

    union(){
        // Head at origin
        head();

        // Threaded shank
        translate([0,0,head_thickness/2 + neck_len + wrench_thickness + shank_relief_len])
            simplified_thread(d=shank_thread_d, L=shank_len, pitch=pitch, depth=0.35);

        // Small chamfer at shank end
        translate([0,0,head_thickness/2 + neck_len + wrench_thickness + shank_relief_len + shank_len])
            cylinder(d1=shank_thread_d-0.6, d2=shank_thread_d-1.6, h=1.2);
    }
}

rod_end_m5();