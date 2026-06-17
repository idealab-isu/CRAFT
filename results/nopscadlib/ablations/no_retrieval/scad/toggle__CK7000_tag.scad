// Toggle switch (single connected solid)
// Target: body diameter = 0.76mm, body height = 4.7mm

$fn = 96;

// Parameters
body_diameter = 0.76;              //[0.38:1.52:0.01]
body_height   = 4.7;               //[2.35:9.4:0.05]

bezel_flange_diameter  = 1.10;     //[0.6:2.2:0.01]
bezel_flange_thickness = 0.25;     //[0.12:0.6:0.01]

thread_diameter = 0.70;            //[0.35:1.4:0.01]
thread_height   = 1.20;            //[0.6:2.4:0.05]

lever_diameter        = 0.25;      //[0.12:0.5:0.01]
lever_length          = 1.80;      //[0.9:3.6:0.05]
lever_tip_diameter    = 0.32;      //[0.16:0.64:0.01]
lever_tip_height      = 0.25;      //[0.12:0.6:0.01]

pin_diameter = 0.18;               //[0.09:0.36:0.01]
pin_length   = 1.20;               //[0.6:2.4:0.05]
pin_spacing  = 0.35;               //[0.18:0.7:0.01]

// Small overlap to guarantee watertight unions
overlap = 0.06;                    //[0.02:0.2:0.01]

// Derived
body_r   = body_diameter/2;
bezel_r  = bezel_flange_diameter/2;
thread_r = thread_diameter/2;

module cyl(h, r, zc) {
    translate([0,0,zc]) cylinder(h=h, r=r, center=true);
}

module toggle_switch() {
    union() {
        // Main body (centered at origin)
        cyl(body_height, body_r, 0);

        // Top bezel flange: sits on top of body with slight overlap
        // Body top face is at +body_height/2
        cyl(bezel_flange_thickness, bezel_r,
            body_height/2 + bezel_flange_thickness/2 - overlap);

        // Mounting threads: above flange, overlapping into flange
        cyl(thread_height, thread_r,
            (body_height/2 + bezel_flange_thickness - overlap) + thread_height/2 - overlap);

        // Toggle lever: starts at top of threads and extends upward
        lever_bottom_z = (body_height/2 + bezel_flange_thickness - overlap) + thread_height - overlap;
        cyl(lever_length, lever_diameter/2,
            lever_bottom_z + lever_length/2);

        // Lever tip: on top of lever with overlap
        cyl(lever_tip_height, lever_tip_diameter/2,
            lever_bottom_z + lever_length - overlap + lever_tip_height/2);

        // Terminal pins: extend downward from body bottom with overlap into body
        pin_top_z = -body_height/2 + overlap;
        for (x = [-pin_spacing/2, 0, pin_spacing/2]) {
            translate([x, 0, pin_top_z - pin_length/2])
                cylinder(h=pin_length, r=pin_diameter/2, center=true);
        }

        // Base boss: ensure pins are visibly connected and robust (within body diameter)
        boss_h = max(overlap*4, 0.12);
        cyl(boss_h, body_r*0.98, -body_height/2 + boss_h/2);

        // Add a small side key/flat so orthographic side/front/back views are recognizable
        // (still a single connected solid; attached to body side with overlap)
        key_w = max(0.14, body_diameter*0.22);   // tangential thickness
        key_len = max(0.22, body_diameter*0.55); // radial protrusion
        key_h = body_height*0.55;                // vertical extent
        translate([body_r + key_len/2 - overlap, 0, 0])
            cube([key_len, key_w, key_h], center=true);
    }
}

toggle_switch();