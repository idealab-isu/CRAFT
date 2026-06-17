// Hex head screw: shank Ø6.0, head Ø11.5 (across flats), head height 4.15, shank length 10
$fn = 96;

module hex_head_screw() {
    shank_d = 6.0;
    shank_len = 10.0;

    head_af = 11.5;          // across flats
    head_h  = 4.15;

    overlap = 0.2;

    union() {
        // Head (hex prism). For $fn=6, OpenSCAD's d is across corners, so convert AF->AC.
        cylinder(h=head_h, d=head_af / cos(30), $fn=6);

        // Threaded shank (simple helical thread approximation) connected to head underside
        translate([0, 0, -shank_len + overlap])
            threaded_rod(len=shank_len + overlap, d=shank_d, pitch=1.0, thread_h=0.35);

        // Slight chamfer at tip
        translate([0, 0, -shank_len])
            cylinder(h=0.8, d1=shank_d*0.85, d2=shank_d, $fn=48);
    }
}

// Simple external thread approximation using linear_extrude with twist
module threaded_rod(len=10, d=6, pitch=1.0, thread_h=0.35) {
    core_d = d - 2*thread_h;
    turns = len / pitch;

    union() {
        // Core
        cylinder(h=len, d=core_d, $fn=64);

        // Helical ridge (triangular-ish profile)
        linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
            translate([core_d/2, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [thread_h, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

hex_head_screw();