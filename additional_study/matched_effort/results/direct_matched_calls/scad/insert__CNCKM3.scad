$fn = 120;

// Threaded heat-set insert (simplified geometric model)
// Outer diameter: 3.0mm
// Length: 4.6mm
// Intended for M3 screws (internal hole sized accordingly)

od = 3.0;
len = 4.6;

// Typical M3 heat-set insert minor diameter is around 3.0mm thread major,
// but internal clearance/drill for modeling: ~2.5mm
id = 2.5;

// Optional small lead-in chamfers
chamfer = 0.25;

module insert_body() {
    // Main cylinder with slight chamfers
    union() {
        // Main section
        translate([0,0,chamfer])
            cylinder(h = len - 2*chamfer, d = od);

        // Bottom chamfer
        cylinder(h = chamfer, d1 = od - 2*chamfer, d2 = od);

        // Top chamfer
        translate([0,0,len - chamfer])
            cylinder(h = chamfer, d1 = od, d2 = od - 2*chamfer);
    }
}

module internal_hole() {
    // Through hole
    translate([0,0,-0.2])
        cylinder(h = len + 0.4, d = id);
}

difference() {
    insert_body();
    internal_hole();
}