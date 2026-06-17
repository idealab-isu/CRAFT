$fn = 96;

// Linear bearing dimensions (mm)
id = 3.0;     // bore diameter
od = 7.0;     // outer diameter
len = 10.0;   // overall length

// Small epsilon to guarantee clean boolean operations
eps = 0.02;

module linear_bearing(id, od, len) {
    difference() {
        // Outer sleeve
        cylinder(h = len, d = od, center = true);

        // Through-bore (slightly longer to ensure it fully cuts)
        cylinder(h = len + 2*eps, d = id, center = true);
    }
}

linear_bearing(id, od, len);