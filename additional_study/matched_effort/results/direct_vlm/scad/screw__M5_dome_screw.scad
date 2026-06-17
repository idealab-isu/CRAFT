$fn = 128;

// Requested dimensions (mm)
shank_d = 5.0;
length  = 10.0;

head_d  = 9.5;
head_h  = 2.75;

// Detail controls
thread_pitch = 0.8;          // visual thread pitch (mm)
thread_depth = 0.35;         // radial depth (mm) (kept modest for robustness)
thread_start_clear = 0.6;    // unthreaded length under head (mm)
thread_end_clear   = 0.4;    // unthreaded at tip (mm)
drive_d = 3.0;               // simple hex socket across flats approx (mm)
drive_depth = 1.4;           // socket depth (mm)

module hex_socket(af=3.0, h=1.4) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    linear_extrude(height=h, center=false)
        polygon([for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module helical_thread_visual(d_core, d_major, pitch, h) {
    // Simple helical ridge (visual thread), unioned to core
    // Uses linear_extrude with twist; ridge is a thin rectangle at radius d_core/2
    turns = h / pitch;
    ridge_w = max(0.25, (d_major - d_core)/2); // radial thickness
    ridge_t = max(0.35, pitch*0.45);           // tangential thickness
    linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*24), 24), center=false)
        translate([d_core/2, 0, 0])
            square([ridge_w, ridge_t], center=true);
}

module dome_head_screw(shank_d, length, head_d, head_h) {
    // Ensure sane parameters
    shank_r = shank_d/2;
    head_r  = head_d/2;

    // Dome profile: spherical cap with exact base radius=head_r and height=head_h
    // Sphere radius R from cap geometry
    a = head_r;
    h = head_h;
    R = (a*a + h*h) / (2*h);

    // Thread geometry
    d_major = shank_d;
    d_core  = max(0.1, d_major - 2*thread_depth);

    // Threaded length (kept within overall shank length)
    thread_h = max(0, length - thread_start_clear - thread_end_clear);

    difference() {
        union() {
            // Core shank (minor diameter) for threads to sit on
            cylinder(d=d_core, h=length, center=false);

            // Visual helical ridge (threads), positioned to start below head
            if (thread_h > 0)
                translate([0,0,thread_end_clear])
                    helical_thread_visual(d_core=d_core, d_major=d_major, pitch=thread_pitch, h=thread_h);

            // Dome head (connected at z=length)
            translate([0,0,length])
                intersection() {
                    // Sphere positioned so cap base is at z=0 and top at z=head_h
                    translate([0,0, h - R]) sphere(r=R);
                    cylinder(r=head_r, h=head_h, center=false);
                }
        }

        // Drive feature: hex socket in the top of the dome head
        // Cut from the top down by drive_depth, staying within head height
        dd = min(drive_depth, head_h - 0.2);
        if (dd > 0)
            translate([0,0,length + head_h - dd])
                hex_socket(af=drive_d, h=dd + 0.2);
    }
}

dome_head_screw(shank_d, length, head_d, head_h);