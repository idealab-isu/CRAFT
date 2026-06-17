$fn = 96;

dims = [6, 5.5, 14.7, 12]; // [shaft_d, shaft_len, body_len, body_d]

shaft_d = dims[0];
shaft_len = dims[1];
body_len  = dims[2];
body_d    = dims[3];

module gear_motor(shaft_d, shaft_len, body_len, body_d) {
    // Main cylindrical body
    color([0.75,0.75,0.78])
    translate([0,0,0])
        cylinder(d=body_d, h=body_len);

    // Front face boss (small step)
    boss_d = body_d * 0.72;
    boss_h = max(1.2, body_len * 0.10);
    color([0.70,0.70,0.72])
    translate([0,0,body_len - boss_h])
        cylinder(d=boss_d, h=boss_h);

    // Output shaft
    color([0.85,0.85,0.88])
    translate([0,0,body_len])
        cylinder(d=shaft_d, h=shaft_len);

    // Rear cap
    cap_h = max(1.0, body_len * 0.08);
    cap_d = body_d * 0.92;
    color([0.55,0.55,0.58])
    translate([0,0,-cap_h])
        cylinder(d=cap_d, h=cap_h);

    // Simple mounting flat (a cut) to suggest gearbox housing
    difference() {
        // invisible wrapper (no-op) to apply cut to body only
        union() {}
        // cut a flat along one side of the body
        translate([body_d*0.35, -body_d, -cap_h-0.1])
            cube([body_d, body_d*2, body_len + cap_h + shaft_len + 0.2], center=false);
    }
}

gear_motor(shaft_d, shaft_len, body_len, body_d);