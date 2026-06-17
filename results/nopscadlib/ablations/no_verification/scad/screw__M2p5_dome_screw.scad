$fn = 96;

// Dome head screw dimensions (mm)
thread_diameter = 2.5;   // major diameter
length          = 10;    // under-head length
head_diameter   = 5.35;  // max head diameter
head_height     = 1.6;   // head height

// Drive feature (Phillips by default)
drive_type      = "phillips"; // "phillips", "slot", "hex", "none"
drive_depth     = 0.9;        // cut depth into head (mm)
slot_width      = 0.8;        // for "slot" (mm)
slot_length     = 3.2;        // for "slot" (mm)
hex_socket_af   = 2.0;        // for "hex" (across flats, mm)

// Thread approximation (visual)
thread_pitch    = 0.45;       // mm (approx for M2.5)
thread_depth    = 0.18;       // radial depth (mm)
thread_starts   = 1;          // 1-start thread

eps = 0.02;

// Spherical cap dome head: base plane at z=0, top at z=h
module dome_head(d, h) {
    a = d/2;
    R = (h*h + a*a) / (2*h);
    intersection() {
        translate([0,0,h - R]) sphere(r=R);
        translate([0,0,h/2]) cylinder(h=h + eps, r=a, center=true);
    }
}

// Simple ISO-ish external thread approximation using a twisted triangular ridge
module external_thread(major_d, len, pitch, depth, starts=1) {
    major_r = major_d/2;
    minor_r = major_r - depth;

    // Core cylinder at minor diameter
    union() {
        cylinder(h=len, r=minor_r, center=false);

        // Helical ridge(s)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*12), 60), convexity=10)
                    translate([minor_r, 0, 0])
                        polygon(points=[
                            [0, -pitch*0.22],
                            [depth, 0],
                            [0,  pitch*0.22]
                        ]);
        }
    }
}

module hex_socket(af, depth) {
    r = af/(2*cos(30));
    cylinder(h=depth + eps, r=r, $fn=6, center=false);
}

module slot_drive(width, length, depth) {
    translate([0,0,-eps])
        cube([length, width, depth + 2*eps], center=true);
}

module phillips_drive(depth, head_d) {
    // Two perpendicular tapered slots (approx)
    w1 = max(0.55, head_d*0.16);
    w2 = max(0.55, head_d*0.12);
    L  = head_d*0.62;

    union() {
        // Main cross
        hull() {
            translate([0,0,0]) cube([L, w1, eps], center=true);
            translate([0,0,depth]) cube([L*0.72, w2, eps], center=true);
        }
        hull() {
            translate([0,0,0]) cube([w1, L, eps], center=true);
            translate([0,0,depth]) cube([w2, L*0.72, eps], center=true);
        }
    }
}

module dome_head_screw() {
    shank_r = thread_diameter/2;

    // Place under-head plane at z=0, shank goes to z=-length, head to z=+head_height
    difference() {
        union() {
            // Threaded shank (connected to head at z=0 with slight overlap)
            translate([0,0,-length])
                external_thread(thread_diameter, length + eps, thread_pitch, thread_depth, thread_starts);

            // Dome head
            dome_head(head_diameter, head_height);
        }

        // Drive feature cut from the top surface downwards
        if (drive_type == "hex") {
            translate([0,0,head_height - drive_depth])
                hex_socket(hex_socket_af, drive_depth);
        } else if (drive_type == "slot") {
            translate([0,0,head_height - drive_depth/2])
                slot_drive(slot_width, slot_length, drive_depth);
        } else if (drive_type == "phillips") {
            translate([0,0,head_height - drive_depth])
                phillips_drive(drive_depth, head_diameter);
        } else {
            // none
        }
    }
}

dome_head_screw();