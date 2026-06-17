// Dome (pan) head screw: 2.5mm major dia, 5.35mm head dia, 1.6mm head height, 10mm long
// One connected solid, with visible (approx) helical threads.

$fn = 96;

// --- Parameters (mm) ---
thread_diameter = 2.5;
length          = 10;

head_diameter   = 5.35;
head_height     = 1.6;

thread_pitch    = 0.45;
thread_depth    = 0.18;   // radial depth (approx)
tip_length      = 0.8;    // small chamfered tip

// Derived
major_r = thread_diameter/2;
minor_r = max(0.01, major_r - thread_depth);

// --- Helpers ---
module dome_head(d=head_diameter, h=head_height) {
    // Spherical cap trimmed to exact height h and diameter d at the base plane (z=0)
    // Base plane at z=0, top at z=h.
    r = ( (d*d) / (8*h) ) + (h/2);          // sphere radius for cap with base diameter d and height h
    zc = h - r;                              // sphere center z so that top is at z=h

    intersection() {
        translate([0,0,zc]) sphere(r=r);
        translate([0,0,h/2]) cylinder(h=h, r=d/2, center=true);
    }
}

module helical_thread(h, pitch, r_minor, r_major) {
    // Simple triangular thread ridge via linear_extrude with twist.
    // Ridge is a thin wedge from r_minor to r_major.
    turns = h / pitch;
    twist_deg = -360 * turns;

    linear_extrude(height=h, twist=twist_deg, slices=max(ceil(turns*24), 24), convexity=10)
        polygon(points=[
            [r_minor, -pitch*0.22],
            [r_major,  0],
            [r_minor,  pitch*0.22]
        ]);
}

module screw() {
    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // shank extends down to z=-length
    union() {
        // Head (dome/pan)
        dome_head(d=head_diameter, h=head_height);

        // Under-head fillet / short collar to ensure robust connection
        translate([0,0,-0.15])
            cylinder(h=0.3, r=major_r, center=false);

        // Threaded shank (approx)
        translate([0,0,-length])
        union() {
            // Core (minor diameter)
            cylinder(h=length, r=minor_r, center=false);

            // Helical ridge (major diameter)
            helical_thread(h=length, pitch=thread_pitch, r_minor=minor_r, r_major=major_r);

            // Tip chamfer
            translate([0,0,0])
                cylinder(h=tip_length, r1=0.2, r2=minor_r, center=false);
        }
    }
}

screw();