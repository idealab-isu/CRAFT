module faceted_spiral() {
    rotate([0, 0, 0])
    scale([1, 1, 1])
    translate([0, 0, -5.8])
    for (i = [0 : 360 / 12 : 360]) {
        rotate([0, 0, i])
        translate([0, 0, i * 0.02])
        rotate([i * 0.5, 0, 0])
        polyhedron(
            points=[
                [0, 0, 0],
                [3.1, 0, 0],
                [0, 3.0, 0],
                [0, 0, 11.6]
            ],
            faces=[
                [0, 1, 2],
                [0, 1, 3],
                [1, 2, 3],
                [2, 0, 3]
            ]
        );
    }
}

faceted_spiral();