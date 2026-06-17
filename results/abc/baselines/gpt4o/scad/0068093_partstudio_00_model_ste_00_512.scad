module mushroom_fastener() {
    $fn = 16; // Low-poly tessellation
    union() {
        // Domed/conical head
        translate([0, 0, 10])
        scale([1, 1, 0.5])
        sphere(r=10);

        // Central cylindrical shank
        cylinder(h=20, r=5, center=true);

        // First retaining flange/rib
        translate([0, 0, -5])
        cylinder(h=2, r=7, center=true);

        // Second retaining flange/rib
        translate([0, 0, 5])
        cylinder(h=2, r=7, center=true);
    }
}

translate([0, 0, -10])
mushroom_fastener();