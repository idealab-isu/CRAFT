$fn = 128;

// PTFE tubing (hollow cylinder) — oriented horizontally for clear side views
outer_d = 4.0;     // mm
inner_d = 2.0;     // mm
length  = 200.0;   // mm

module ptfe_tube(od, id, len) {
    eps = 0.2; // overlap to ensure clean subtraction
    difference() {
        // Outer tube
        rotate([0, 90, 0]) cylinder(d=od, h=len, center=true);
        // Inner bore (slightly longer to fully cut through)
        rotate([0, 90, 0]) cylinder(d=id, h=len + 2*eps, center=true);
    }
}

color([0.95, 0.95, 0.95])
ptfe_tube(outer_d, inner_d, length);