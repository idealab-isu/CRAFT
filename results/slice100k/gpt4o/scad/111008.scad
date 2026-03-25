module star_lobe() {
    polyhedron(
        points=[
            [0, 0, 0],  // Central point
            [27.2, 0, 0],  // Base points of the lobe
            [-27.2, 0, 0],
            [0, 28.55, 0],
            [0, -28.55, 0],
            [0, 0, 90]  // Apex of the lobe
        ],
        faces=[
            [0, 1, 5],
            [0, 2, 5],
            [0, 3, 5],
            [0, 4, 5],
            [1, 3, 5],
            [3, 2, 5],
            [2, 4, 5],
            [4, 1, 5]
        ]
    );
}

module star() {
    for (i = [0:4]) {
        rotate([0, 0, i * 72])
        star_lobe();
    }
}

translate([0, 0, -45])
star();