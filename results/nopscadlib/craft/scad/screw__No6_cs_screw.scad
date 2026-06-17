// Screw: 3.5mm shaft diameter, 7.0mm head diameter, 10mm overall length
// One connected solid, with threads, pointed tip, and a simple Phillips drive.

$fn = 96;

// --- Key dimensions (mm) ---
shaft_diameter = 3.5;
shaft_radius   = shaft_diameter/2;

head_diameter  = 7.0;
head_radius    = head_diameter/2;

length         = 10.0;          // overall length (tip to head top)

// Head proportions
head_height    = 2.5;

// Tip + threaded section
tip_length     = 1.2;           // pointed tip length
thread_length  = length - head_height - tip_length;  // threaded length under head

// Thread geometry (approximate)
thread_pitch   = 0.8;
thread_depth   = 0.35;          // radial depth of thread
thread_r_major = shaft_radius + thread_depth;
thread_r_minor = shaft_radius - 0.10; // slight undercut for thread root

// Drive feature (Phillips-like cross)
drive_depth    = 1.2;
drive_w        = 0.9;
drive_len      = head_diameter * 0.75;

// Small overlap to ensure watertight unions
overlap = 0.15;

module thread_helix(len, pitch, r_major, r_minor) {
    turns = len / pitch;

    // Build a helical "rib" by twisting a small triangular profile.
    // Use an XY profile located at the correct radius; extrude along Z with twist.
    linear_extrude(
        height = len,
        twist = 360 * turns,
        slices = max(ceil(turns * 32), 32),
        convexity = 10
    )
    polygon(points=[
        [r_minor, -pitch*0.18],
        [r_major,  0],
        [r_minor,  pitch*0.18]
    ]);
}

module pointed_tip(tip_len, r_base) {
    cylinder(h = tip_len, r1 = 0, r2 = r_base, center = false);
}

module phillips_cut(depth, w, len) {
    union() {
        translate([0, 0, -depth/2])
            cube([len, w, depth], center = true);
        translate([0, 0, -depth/2])
            cube([w, len, depth], center = true);
    }
}

module screw_solid() {
    // z=0 at tip point, z=length at head top
    union() {
        // Tip
        pointed_tip(tip_length, thread_r_minor);

        // Core shaft (minor diameter) under threads
        translate([0, 0, tip_length - overlap])
            cylinder(h = thread_length + 2*overlap, r = thread_r_minor, center = false);

        // Threads (add material around core)
        translate([0, 0, tip_length - overlap])
            thread_helix(thread_length + 2*overlap, thread_pitch, thread_r_major, thread_r_minor);

        // Head
        translate([0, 0, length - head_height])
            cylinder(h = head_height, r = head_radius, center = false);
    }
}

difference() {
    screw_solid();

    // Phillips drive cut from the top of the head downward
    translate([0, 0, length])
        phillips_cut(drive_depth, drive_w, drive_len);
}