$fn = 64;

length = 100;
size = 20;

difference() {
    // Outer body
    cube([size, size, length], center=false);

    // Central bore (typical for 2020-style extrusion)
    translate([size/2, size/2, -0.5])
        cylinder(h=length+1, d=5.2, center=false);

    // Four T-slots (simplified)
    for (rot = [0, 90, 180, 270]) {
        rotate([0, 0, rot]) {
            // Slot opening from the outside
            translate([size/2 - 0.01, size/2, -0.5])
                cube([6.2, 6.0, length+1], center=true);

            // Inner cavity behind the opening
            translate([size/2 - 3.0, size/2, -0.5])
                cube([8.0, 10.0, length+1], center=true);
        }
    }

    // Corner reliefs (simplified)
    for (sx = [0, 1], sy = [0, 1]) {
        translate([sx*size, sy*size, -0.5])
            translate([sx ? -3.0 : 0, sy ? -3.0 : 0, 0])
                cylinder(h=length+1, r=3.0, center=false);
    }
}