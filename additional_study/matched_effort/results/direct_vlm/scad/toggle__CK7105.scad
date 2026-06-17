$fn = 96;

// Requested main body size
body_d = 6.86;
body_h = 12.7;

// Simple toggle-switch details (kept connected, no floating parts)
base_flange_d = 7.4;
base_flange_h = 1.2;

bushing_d = 5.8;
bushing_h = 2.2;

washer_d = 7.6;
washer_thk = 0.6;

nut_flat = 8.0;
nut_thk  = 1.6;

boot_d = 9.2;      // toggle "boot"/shoulder to make side views recognizable
boot_h = 3.0;

lever_d = 2.2;
lever_h = 10.0;    // lever above nut

tip_d = 3.2;
tip_h = 3.0;

tilt_deg = 18;     // toggle angle
overlap = 0.25;    // small overlap to guarantee manifold union

module hex_prism(flat=8, h=1.6){
    // flat-to-flat = flat
    r = flat / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module toggle_switch(){
    union(){
        // Main cylindrical body (exact requested size)
        cylinder(h=body_h, d=body_d);

        // Base flange (connected with overlap)
        translate([0,0,-base_flange_h + overlap])
            cylinder(h=base_flange_h, d=base_flange_d);

        // Boot/shoulder near top of body to read as a toggle switch in side views
        boot_z0 = body_h - boot_h;
        translate([0,0,boot_z0 - overlap])
            cylinder(h=boot_h + overlap, d=boot_d);

        // Threaded bushing section on top (connected)
        translate([0,0,body_h - overlap])
            cylinder(h=bushing_h + overlap, d=bushing_d);

        // Washer (connected)
        washer_z0 = body_h + bushing_h;
        translate([0,0,washer_z0 - overlap])
            cylinder(h=washer_thk + overlap, d=washer_d);

        // Hex nut (connected)
        nut_z0 = washer_z0 + washer_thk;
        translate([0,0,nut_z0 - overlap])
            hex_prism(flat=nut_flat, h=nut_thk + overlap);

        // Lever (tilted) starting at top of nut, with overlap into nut
        lever_z0 = nut_z0 + nut_thk;
        translate([0,0,lever_z0 - overlap])
            rotate([tilt_deg, 0, 0])
                cylinder(h=lever_h + overlap, d=lever_d);

        // Tip at end of lever (tilted), connected by overlap
        translate([0,0,lever_z0 - overlap])
            rotate([tilt_deg, 0, 0])
                translate([0,0,lever_h - overlap])
                    cylinder(h=tip_h, d=tip_d);
    }
}

toggle_switch();