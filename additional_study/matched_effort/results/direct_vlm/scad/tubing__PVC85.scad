$fn = 128;

// PVC aquarium tubing (hollow flexible tube)
// Make it readable in all orthographic views by orienting the tube along X (not Z).
inner_d = 4;      // mm
outer_d = 6;      // mm
length  = 200;    // mm

module tubing(od, id, len) {
    difference() {
        // Outer tube along X axis
        rotate([0, 90, 0])
            cylinder(h = len, d = od, center = true);

        // Inner bore (slightly longer to ensure clean subtraction)
        rotate([0, 90, 0])
            cylinder(h = len + 1, d = id, center = true);
    }
}

tubing(outer_d, inner_d, length);