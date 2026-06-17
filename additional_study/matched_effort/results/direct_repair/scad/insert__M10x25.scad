$fn = 180;

// Threaded heat-set insert (simplified, renderable model)
// Specs from prompt:
// - Outer diameter: 25.0 mm
// - Length: 18.5 mm
// - For 10.0 mm screws (modeled as internal M10x1.5 thread)
// Notes: Heat-set inserts are typically knurled; this model includes a knurled outer surface
// and a modeled internal thread. Dimensions are approximate where not specified.

outer_d = 25.0;
length  = 18.5;

// Internal thread (for 10 mm screws)
thread_major_d = 10.0;   // M10 major diameter
thread_pitch   = 1.5;    // common coarse pitch for M10
thread_depth   = 0.65;   // approximate radial thread depth
thread_clear   = 0.20;   // clearance to make it printable/renderable
bore_d = thread_major_d - 2*thread_depth + thread_clear;

// Lead-in chamfers
outer_chamfer = 1.0;
inner_chamfer = 0.8;

// Knurling
knurl_depth = 0.6;
knurl_count = 48;        // number of knurl ridges around circumference
knurl_twist = 25;        // degrees of twist over length (gives helical knurl feel)

// Thread modeling resolution
thread_slices_per_turn = 36;

module helical_thread_internal(major_d=10, pitch=1.5, len=18.5, depth=0.65, clearance=0.2) {
    // Creates a subtractive internal thread volume.
    // We subtract a helical "tooth" around a cylinder.
    turns = len / pitch;
    steps = max(ceil(turns * thread_slices_per_turn), 10);
    step_h = len / steps;
    step_ang = 360 * turns / steps;

    // Base cylinder to ensure continuous subtraction
    union() {
        cylinder(h=len, d=major_d + 2*clearance, center=false);

        // Helical groove/tooth subtraction volume
        for (i = [0:steps-1]) {
            z0 = i * step_h;
            a0 = i * step_ang;

            // A small wedge-like cutter placed at the thread radius and rotated along Z
            // Using hull between successive positions to form a continuous helix.
            hull() {
                translate([0,0,z0])
                    rotate([0,0,a0])
                        translate([major_d/2 - depth, 0, 0])
                            rotate([0,90,0])
                                linear_extrude(height=depth*2, center=true)
                                    polygon(points=[
                                        [0, -pitch*0.30],
                                        [0,  pitch*0.30],
                                        [pitch*0.55, 0]
                                    ]);

                translate([0,0,z0 + step_h])
                    rotate([0,0,a0 + step_ang])
                        translate([major_d/2 - depth, 0, 0])
                            rotate([0,90,0])
                                linear_extrude(height=depth*2, center=true)
                                    polygon(points=[
                                        [0, -pitch*0.30],
                                        [0,  pitch*0.30],
                                        [pitch*0.55, 0]
                                    ]);
            }
        }
    }
}

module knurled_shell(od=25, h=18.5, depth=0.6, count=48, twist=25) {
    // Outer knurl as intersected twisted ridges
    base = cylinder(h=h, d=od, center=false);

    // Create ridges by subtracting shallow grooves (two directions) from the base
    difference() {
        // Slightly oversized base to keep OD close after grooves
        cylinder(h=h, d=od, center=false);

        // Grooves direction 1
        for (k = [0:count-1]) {
            ang = 360*k/count;
            rotate([0,0,ang])
                translate([od/2 - depth/2, 0, 0])
                    linear_extrude(height=h, twist=twist, slices=ceil(h*6), center=false)
                        square([depth, od], center=true);
        }

        // Grooves direction 2 (crosshatch)
        for (k = [0:count-1]) {
            ang = 360*k/count + 180/count;
            rotate([0,0,ang])
                translate([od/2 - depth/2, 0, 0])
                    linear_extrude(height=h, twist=-twist, slices=ceil(h*6), center=false)
                        square([depth, od], center=true);
        }
    }
}

module heat_set_insert() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main knurled body
            knurled_shell(od=outer_d, h=length, depth=knurl_depth, count=knurl_count, twist=knurl_twist);

            // Outer chamfers (add then cut to shape via intersection-like approach)
            // We'll just add small cones at ends to approximate chamfered edges.
            // Top chamfer
            translate([0,0,length-outer_chamfer])
                cylinder(h=outer_chamfer, d1=outer_d, d2=outer_d-2*outer_chamfer, center=false);
            // Bottom chamfer
            cylinder(h=outer_chamfer, d1=outer_d-2*outer_chamfer, d2=outer_d, center=false);
        }

        // Central bore (minor diameter region)
        translate([0,0,0])
            cylinder(h=length, d=bore_d, center=false);

        // Internal thread subtraction (approximate)
        translate([0,0,0])
            helical_thread_internal(major_d=thread_major_d, pitch=thread_pitch, len=length, depth=thread_depth, clearance=thread_clear);

        // Inner chamfers at both ends
        // Bottom inner chamfer
        cylinder(h=inner_chamfer, d1=bore_d + 2*inner_chamfer, d2=bore_d, center=false);
        // Top inner chamfer
        translate([0,0,length-inner_chamfer])
            cylinder(h=inner_chamfer, d1=bore_d, d2=bore_d + 2*inner_chamfer, center=false);
    }
}

heat_set_insert();