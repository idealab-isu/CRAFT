$fn = 128;

// Brushless DC motor with 28.0mm stator diameter and 27.0mm stator height
stator_d = 28.0;
stator_h = 27.0;

// Outrunner-style can around stator
can_wall = 1.2;
air_gap  = 0.6;
can_d    = stator_d + 2*(air_gap + can_wall);

// Endbells / plates (kept thin so stator height remains exactly 27mm)
endbell_th = 2.0;
motor_h    = stator_h + 2*endbell_th;

// Shaft
shaft_d         = 3.0;
shaft_len_above = 12.0;
shaft_len_below = 3.0;

// Mounting pattern (front endbell)
mount_hole_d     = 2.2;
mount_hole_r     = 9.5;
mount_hole_count = 4;

// Internal rotor hub + spokes (visual detail)
hub_d     = 10.0;
hub_h     = stator_h * 0.55;
spoke_w   = 2.0;
spoke_t   = 2.0;
spoke_cnt = 6;

// Stator teeth (visual detail)
tooth_cnt     = 12;
tooth_len     = 2.2;   // radial protrusion
tooth_w       = 2.0;   // tangential width
tooth_h       = stator_h * 0.85;
tooth_overlap = 0.6;

// External can ribs (so side orthographic views show features)
rib_cnt     = 12;
rib_w       = 1.2;                 // tangential width
rib_rad     = 0.8;                 // radial protrusion
rib_h       = stator_h * 0.85;
rib_overlap = 0.4;                 // overlap into can

// Wire exit (consistent orientation: +X side)
wire_d   = 4.0;
wire_len = 6.0;
wire_z   = endbell_th + stator_h*0.25; // measured from bottom

eps = 0.2;

module stator_with_teeth() {
    union() {
        // Stator core (exact: 28mm diameter, 27mm height)
        cylinder(d=stator_d, h=stator_h);

        // Teeth protruding outward from stator OD
        for (i = [0:tooth_cnt-1]) {
            rotate([0,0,i*360/tooth_cnt])
                translate([stator_d/2 + tooth_len/2 - tooth_overlap, 0, (stator_h - tooth_h)/2])
                    cube([tooth_len, tooth_w, tooth_h], center=false);
        }
    }
}

module rotor_detail() {
    union() {
        // Hub
        translate([0,0,(stator_h-hub_h)/2])
            cylinder(d=hub_d, h=hub_h);

        // Spokes to suggest rotor structure
        for (i = [0:spoke_cnt-1]) {
            rotate([0,0,i*360/spoke_cnt])
                translate([hub_d/2 - 0.2, -spoke_w/2, stator_h/2 - spoke_t/2])
                    cube([stator_d/2 - hub_d/2 + 0.2, spoke_w, spoke_t], center=false);
        }
    }
}

module can_shell_with_ribs() {
    union() {
        // Outer can shell (connected between endbells)
        difference() {
            cylinder(d=can_d, h=stator_h);
            translate([0,0,-eps])
                cylinder(d=can_d - 2*can_wall, h=stator_h + 2*eps);
        }

        // External ribs so orthographic side views show motor features
        for (i = [0:rib_cnt-1]) {
            rotate([0,0,i*360/rib_cnt])
                translate([can_d/2 + rib_rad/2 - rib_overlap, -rib_w/2, (stator_h - rib_h)/2])
                    cube([rib_rad, rib_w, rib_h], center=false);
        }
    }
}

module motor_solid() {
    union() {
        // Bottom endbell (solid)
        cylinder(d=can_d, h=endbell_th);

        // Top endbell (solid)
        translate([0,0,endbell_th + stator_h])
            cylinder(d=can_d, h=endbell_th);

        // Can shell + ribs
        translate([0,0,endbell_th])
            can_shell_with_ribs();

        // Stator (connected to bottom endbell)
        translate([0,0,endbell_th])
            stator_with_teeth();

        // Rotor detail (inside)
        translate([0,0,endbell_th])
            rotor_detail();

        // Shaft (passes through entire motor; ensures single connected solid)
        translate([0,0,-shaft_len_below])
            cylinder(d=shaft_d, h=motor_h + shaft_len_above + shaft_len_below);

        // Wire exit nub (connected to can at +X)
        translate([can_d/2 - wire_len + 0.8, 0, wire_z])
            rotate([0,90,0])
                cylinder(d=wire_d, h=wire_len);
    }
}

difference() {
    motor_solid();

    // Mounting holes through bottom endbell (z: 0..endbell_th)
    for (i = [0:mount_hole_count-1]) {
        a = i * 360/mount_hole_count;
        translate([mount_hole_r*cos(a), mount_hole_r*sin(a), -eps])
            cylinder(d=mount_hole_d, h=endbell_th + 2*eps);
    }

    // Center clearance through bottom endbell
    translate([0,0,-eps])
        cylinder(d=8, h=endbell_th + 2*eps);
}