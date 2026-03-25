module mounting_clip() {
    difference() {
        union() {
            // Base plate
            translate([-2.7, -0.7, 0])
            cube([5.4, 1.4, 1.0]);

            // Central raised spine
            translate([-0.5, -0.5, 1.0])
            cube([1.0, 1.4, 8.0]);

            // U-shaped cradle
            translate([-2.7, -0.7, 8.0])
            rotate([0, 90, 0])
            cylinder(h=1.4, r=2.7, $fn=64);

            // End nubs
            translate([-2.7, 0.7, 8.0])
            rotate([0, 90, 0])
            cylinder(h=1.4, r=0.7, $fn=64);

            translate([2.7, 0.7, 8.0])
            rotate([0, 90, 0])
            cylinder(h=1.4, r=0.7, $fn=64);
        }
        // Cut out the inner part of the U-shaped cradle
        translate([-2.7, -0.7, 8.0])
        rotate([0, 90, 0])
        cylinder(h=1.4, r=2.0, $fn=64);
    }
}

mounting_clip();