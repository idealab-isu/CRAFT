$fn = 120;

// Timing pulley (simplified) with 12 teeth and 7.15mm pitch diameter.
// This is a geometric approximation: teeth are modeled as radial rectangular lugs.

teeth = 12;
pitch_d = 7.15;          // mm
pitch_r = pitch_d/2;

pulley_height = 8;       // mm
hub_d = 10;              // mm (body diameter, includes tooth root)
bore_d = 3;              // mm (shaft hole)

tooth_radial = 1.2;      // mm (tooth height above hub OD/2)
tooth_tangential = 1.4;  // mm (tooth width along circumference at pitch radius)

module pulley() {
    difference() {
        union() {
            // Main body
            cylinder(h=pulley_height, d=hub_d);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    translate([pitch_r, 0, 0])
                        cube([tooth_radial, tooth_tangential, pulley_height], center=true);
            }
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(h=pulley_height+1, d=bore_d);
    }
}

pulley();