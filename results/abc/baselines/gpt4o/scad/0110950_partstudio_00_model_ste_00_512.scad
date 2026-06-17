$fn=64;

module wedge_block() {
    difference() {
        union() {
            // Main prismatic body
            translate([-50, -5, -5])
                cube([100, 10, 10]);
            // Wedge end
            translate([50, -5, -5])
                linear_extrude(height=10)
                    polygon(points=[[0, 0], [10, 5], [0, 10]]);
        }
        // U-shaped clevis/handle cutout
        translate([-50, -2.5, -2.5])
            cube([10, 5, 5]);
    }
}

module clevis_handle() {
    difference() {
        // U-shaped clevis
        translate([-50, -5, -5])
            cube([10, 10, 10]);
        // Arched cutout
        translate([-50, -5, -5])
            cylinder(h=10, r=2.5, center=true);
    }
}

module wedge_with_clevis() {
    union() {
        wedge_block();
        clevis_handle();
    }
}

wedge_with_clevis();