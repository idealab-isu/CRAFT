$fn=128;

// Ring terminal parameters (mm)
ring_od        = 12;   // outer diameter of ring
ring_id        = 6.4;  // inner hole diameter
ring_thickness = 1.6;  // thickness (Z)

neck_len       = 6;    // length from ring tangent to barrel start
neck_w         = 6;    // width of neck
neck_th        = 1.6;  // thickness (Z), usually same as ring_thickness

barrel_len     = 14;   // length of crimp barrel
barrel_od      = 6.5;  // outer diameter of barrel
barrel_id      = 3.2;  // wire hole diameter

flare_len      = 2.5;  // small flare at barrel entry
flare_od       = 7.2;  // flare outer diameter

// Derived
ring_r = ring_od/2;
barrel_r = barrel_od/2;

module ring_terminal() {
    difference() {
        union() {
            // Ring (flat washer)
            cylinder(h=ring_thickness, d=ring_od);

            // Neck (flat strap) from ring to barrel
            translate([ring_r, -neck_w/2, 0])
                cube([neck_len, neck_w, neck_th]);

            // Barrel (tube) aligned along +X, centered on Y, sitting on Z=0
            translate([ring_r + neck_len, 0, barrel_od/2])
                rotate([0,90,0])
                    cylinder(h=barrel_len, d=barrel_od);

            // Entry flare (short cone)
            translate([ring_r + neck_len, 0, barrel_od/2])
                rotate([0,90,0])
                    cylinder(h=flare_len, d1=flare_od, d2=barrel_od);
        }

        // Ring hole
        translate([0,0,-0.1])
            cylinder(h=ring_thickness+0.2, d=ring_id);

        // Barrel wire hole (through)
        translate([ring_r + neck_len - 0.1, 0, barrel_od/2])
            rotate([0,90,0])
                cylinder(h=barrel_len+0.2, d=barrel_id);

        // Slight relief under neck to soften transition (optional)
        // (keeps model printable while looking more like stamped part)
        translate([ring_r-0.5, 0, ring_thickness/2])
            rotate([0,90,0])
                cylinder(h=neck_len+1.0, d=ring_thickness*1.2, center=true);
    }
}

ring_terminal();