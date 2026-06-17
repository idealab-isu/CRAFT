$fn = 96;

// Requested main body dimensions
body_d = 6.86;
body_h = 12.7;

// Small overlap to guarantee watertight unions
overlap = 0.25;

// Bushing / thread stub (above body)
bushing_d = 7.5;
bushing_h = 2.0;

// Panel collar / shoulder (flange)
collar_d = 9.0;
collar_h = 1.5;

// Small boot/neck between collar and lever
neck_d = 4.0;
neck_h = 1.2;

// Toggle lever (actuator)
lever_d = 2.2;
lever_h = 8.0;
lever_tilt_deg = 18;

// Terminals (3 pins) under body
pin_d = 1.0;
pin_len = 3.0;
pin_spacing = 3.0;   // center-to-center for outer pins

module toggle_switch() {
    union() {
        // Main cylindrical body (z: 0 .. body_h)
        cylinder(d=body_d, h=body_h, center=false);

        // Bushing / thread stub (connected to top of body)
        translate([0, 0, body_h - overlap])
            cylinder(d=bushing_d, h=bushing_h + overlap, center=false);

        // Panel collar / shoulder (connected to top of bushing)
        translate([0, 0, body_h + bushing_h - overlap])
            cylinder(d=collar_d, h=collar_h + overlap, center=false);

        // Neck (connected to top of collar)
        translate([0, 0, body_h + bushing_h + collar_h - overlap])
            cylinder(d=neck_d, h=neck_h + overlap, center=false);

        // Lever (tilted), connected to top of neck
        // Use center=true so rotation doesn't swing the base away from the neck.
        translate([0, 0, body_h + bushing_h + collar_h + neck_h - overlap])
            rotate([lever_tilt_deg, 0, 0])
                translate([0, 0, (lever_h + overlap)/2])
                    cylinder(d=lever_d, h=lever_h + overlap, center=true);

        // Terminal pins (3), connected to bottom of body (z: -pin_len .. 0)
        for (x = [-pin_spacing/2, 0, pin_spacing/2]) {
            translate([x, 0, -pin_len + overlap])
                cylinder(d=pin_d, h=pin_len + overlap, center=false);
        }
    }
}

toggle_switch();