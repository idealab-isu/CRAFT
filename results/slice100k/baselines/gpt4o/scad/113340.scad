module wedge_clevis() {
    difference() {
        union() {
            // Central block
            translate([-27.25, -11.1, -14.75])
                cube([54.5, 22.2, 29.5]);

            // Flared arms
            translate([-27.25, -11.1, -14.75])
                scale([1, 1, 0.5])
                rotate([0, 0, 45])
                cube([54.5, 22.2, 29.5]);
        }

        // Triangular through-openings
        translate([-27.25, 0, -14.75])
            rotate([0, 90, 0])
            pyramid_tunnel();

        translate([27.25, 0, -14.75])
            rotate([0, -90, 0])
            pyramid_tunnel();
    }
}

module pyramid_tunnel() {
    polyhedron(
        points=[
            [0, 0, 0], [0, 22.2, 0], [0, 11.1, 29.5],
            [54.5, 0, 0], [54.5, 22.2, 0], [54.5, 11.1, 29.5]
        ],
        faces=[
            [0, 1, 2], [3, 4, 5],
            [0, 1, 4, 3], [1, 2, 5, 4], [2, 0, 3, 5]
        ]
    );
}

wedge_clevis();