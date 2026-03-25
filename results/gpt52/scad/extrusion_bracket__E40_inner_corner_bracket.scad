$fn=64;

size = [38, 31, 8.5];

module extrusion_bracket(sz=[38,31,8.5], corner_r=2) {
    x = sz[0];
    y = sz[1];
    z = sz[2];

    difference() {
        // Main body with slightly rounded corners
        linear_extrude(height=z, center=true)
            offset(r=corner_r)
                offset(delta=-corner_r)
                    square([x, y], center=true);

        // Two mounting holes along the long axis
        for (sx = [-1, 1]) {
            translate([sx*(x*0.25), 0, 0])
                cylinder(h=z+2, d=5, center=true);
        }

        // Central relief slot
        translate([0, 0, 0])
            cube([x*0.55, y*0.25, z+2], center=true);
    }
}

extrusion_bracket(size, corner_r=2);