$fn=96;

// Ring terminal parameters (mm)
ring_od        = 14;   // outer diameter of ring
ring_id        = 6.5;  // inner hole diameter
ring_thickness = 1.6;  // thickness (Z)

neck_len       = 10;   // length from ring to barrel
neck_w         = 6.0;  // width of neck
neck_thickness = 1.6;  // thickness (Z)

barrel_len     = 14;   // length of crimp barrel
barrel_od      = 6.0;  // outer diameter of barrel
barrel_id      = 3.2;  // wire hole diameter

flare_len      = 2.0;  // small flare at barrel entry
flare_od       = 6.8;  // flare outer diameter

// Small fillet-like rounding via hull between primitives
module ring_terminal() {
    union() {
        // Ring (washer)
        difference() {
            cylinder(h=ring_thickness, d=ring_od);
            translate([0,0,-0.2]) cylinder(h=ring_thickness+0.4, d=ring_id);
        }

        // Neck (flat strap) blended to ring and barrel
        translate([0,0,0]) hull() {
            // Strap block
            translate([ring_od/2 - 0.2, -neck_w/2, 0])
                cube([neck_len, neck_w, neck_thickness]);

            // Small pad on ring edge to blend
            translate([ring_od/2 - 0.6, 0, ring_thickness/2])
                cylinder(h=neck_thickness, d=neck_w*0.9, center=true);

            // Small pad near barrel start to blend
            translate([ring_od/2 + neck_len - 0.6, 0, neck_thickness/2])
                cylinder(h=neck_thickness, d=barrel_od*0.95, center=true);
        }

        // Barrel (crimp tube) with through-hole
        translate([ring_od/2 + neck_len, 0, 0])
        difference() {
            union() {
                // Main barrel
                cylinder(h=barrel_len, d=barrel_od);

                // Entry flare
                translate([0,0,0])
                    cylinder(h=flare_len, d1=flare_od, d2=barrel_od);
            }
            // Wire hole
            translate([0,0,-0.2]) cylinder(h=barrel_len+0.4, d=barrel_id);
        }
    }
}

// Orient so ring lies in XY plane, barrel extends in +X
// Current construction has barrel along +Z; rotate to +X.
rotate([0,90,0]) ring_terminal();