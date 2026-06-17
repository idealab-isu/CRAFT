$fn=96;

// Minimal "component": a small mounting block with a through-hole and a counterbore.
module component() {
    difference() {
        // Main body
        cube([40, 20, 12], center=true);

        // Through hole (M4-ish)
        translate([0, 0, 0])
            cylinder(h=30, r=2.2, center=true);

        // Counterbore on top
        translate([0, 0, 4])
            cylinder(h=10, r=4.2, center=true);

        // Light chamfer-ish edge relief (simple)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*20, sy*10, 0])
                rotate([0,0,45])
                    cube([6,6,30], center=true);
        }
    }
}

component();