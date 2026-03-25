$fn = 96;

// Target: toggle switch, 1.0mm body diameter, 4.7mm tall (bottom of body to top of lever)

// Parameters
body_diameter   = 1.0;   //[0.5:2.0:0.05]
overall_height  = 4.7;   //[2.35:9.4:0.1]

// Proportions (kept small but visually "toggle-like")
body_height     = 3.2;   //[1.6:6.4:0.1]   // cylindrical body height
collar_diameter = 1.4;   //[0.8:2.8:0.05]
collar_height   = 0.6;   //[0.3:1.2:0.05]

// Toggle lever (a tilted rod with a rounded tip)
lever_diameter  = 0.35;  //[0.2:0.8:0.05]
lever_tilt_deg  = 25;    //[0:45:1]        // tilt away from vertical
overlap         = 0.10;  //[0.02:0.5:0.01]

// Derived
body_r   = body_diameter/2;
collar_r = collar_diameter/2;
lever_r  = lever_diameter/2;

// Lever height above the top of the body so total height matches overall_height
lever_height = max(0.20, overall_height - body_height);

// Helper: capsule (cylinder + hemispherical ends), centered on Z
module capsule_z(r, h, center=true) {
    hh = max(0.01, h - 2*r);
    translate([0,0, center ? 0 : h/2])
    union() {
        if (hh > 0)
            cylinder(r=r, h=hh, center=true);
        translate([0,0, hh/2]) sphere(r=r);
        translate([0,0,-hh/2]) sphere(r=r);
    }
}

module toggle_switch() {
    union() {
        // Main cylindrical body: bottom at z=0, top at z=body_height
        translate([0,0, body_height/2])
            cylinder(r=body_r, h=body_height, center=true);

        // Mounting collar near the top of the body, overlapping into it
        translate([0,0, body_height - collar_height/2])
            cylinder(r=collar_r, h=collar_height + overlap, center=true);

        // Toggle lever: tilted capsule starting at body top, extending upward
        // Place lever so its lowest point overlaps slightly into the body top.
        translate([0,0, body_height - overlap/2])
            rotate([0, lever_tilt_deg, 0])
                translate([0,0, lever_height/2])
                    capsule_z(r=lever_r, h=lever_height + overlap, center=true);

        // Small "pivot boss" at the lever base to read more like a toggle joint
        pivot_r = max(lever_r*1.35, 0.18);
        translate([0,0, body_height - overlap/2])
            sphere(r=pivot_r);
    }
}

toggle_switch();