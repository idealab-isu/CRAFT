// Standoff pillar: M3 thread, 10mm long, diameter unspecified ("None") -> choose a reasonable default
// One connected solid with visible external helical thread along full length.

thread_major_d_mm = 3.0;     // M3 major diameter
length_mm         = 10.0;    // overall length
pitch_mm          = 0.5;     // M3 coarse pitch (visual/typical)
thread_depth_mm   = 0.25;    // radial thread height (visual)
core_d_mm         = thread_major_d_mm - 2*thread_depth_mm; // minor/core diameter

$fn = 96;

// Helical external thread (approx) using linear_extrude twist of a small triangular rib
module external_thread(d_major, d_core, pitch, len) {
    turns = len / pitch;
    twist_deg = 360 * turns;

    // Rib thickness along Z per turn; keep small so it reads as thread
    rib_z = pitch * 0.55;

    union() {
        // Core cylinder
        cylinder(h=len, r=d_core/2, center=true);

        // Helical rib added to core
        linear_extrude(height=len, twist=twist_deg, center=true, convexity=10, slices=max(ceil(turns*24), 24))
            translate([d_core/2, 0, 0])
                polygon(points=[
                    [0, -rib_z/2],
                    [d_major/2 - d_core/2, 0],
                    [0,  rib_z/2]
                ]);
    }
}

external_thread(thread_major_d_mm, core_d_mm, pitch_mm, length_mm);