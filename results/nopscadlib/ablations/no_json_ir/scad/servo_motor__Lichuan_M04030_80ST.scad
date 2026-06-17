$fn = 96;

// Approximate dimensions (mm) for Lichuan -80M04030B style servo motor
motor_length = 80;
motor_diameter = 40;

shaft_diameter = 8;
shaft_length = 30;

flange_thickness = 5;
flange_diameter = 50;

bolt_hole_diameter = 3;
bolt_circle_diameter = 45;

keyway_width = 2;
keyway_depth = 1;

rear_connector_length = 10;
rear_connector_diameter = 15;

overlap = 0.6; // small overlap to guarantee watertight unions

module servo_motor() {
    difference() {
        // ONE connected solid (union of all positive geometry)
        union() {
            // Main motor body centered at origin
            cylinder(h = motor_length, d = motor_diameter, center = true);

            // Front flange: attached to front face with slight overlap
            translate([0, 0, motor_length/2 + flange_thickness/2 - overlap])
                cylinder(h = flange_thickness, d = flange_diameter, center = true);

            // Output shaft: attached to front flange with slight overlap
            translate([0, 0, motor_length/2 + flange_thickness - overlap + shaft_length/2])
                cylinder(h = shaft_length, d = shaft_diameter, center = true);

            // Rear endcap: attached to rear face with slight overlap
            translate([0, 0, -motor_length/2 - flange_thickness/2 + overlap])
                cylinder(h = flange_thickness, d = motor_diameter, center = true);

            // Rear connector: attached to rear endcap with slight overlap
            translate([0, 0, -motor_length/2 - flange_thickness + overlap - rear_connector_length/2])
                cylinder(h = rear_connector_length, d = rear_connector_diameter, center = true);
        }

        // Subtractions (holes/keyway) keep model as ONE connected solid
        union() {
            // Mounting holes through flange (4x on bolt circle)
            for (i = [0:3]) {
                rotate([0, 0, i * 90])
                    translate([bolt_circle_diameter/2, 0, motor_length/2 + flange_thickness/2 - overlap])
                        cylinder(h = flange_thickness + 2*overlap, d = bolt_hole_diameter, center = true);
            }

            // Shaft keyway/flat: subtract a small rectangular notch from shaft
            // Positioned to intersect the shaft near its base; extends along shaft length.
            translate([
                -keyway_width/2,
                shaft_diameter/2 - keyway_depth,
                motor_length/2 + flange_thickness - overlap
            ])
                cube([keyway_width, keyway_depth + overlap, shaft_length + 2*overlap], center = false);
        }
    }
}

servo_motor();