module arrow_indicator() {
    // Main body
    translate([-10.3, -30.2, -4.2])
    cube([20.6, 60.4, 4.2]);

    // Left tip
    translate([-10.3, -30.2, -4.2])
    polyhedron(
        points=[
            [0, 0, 0], [0, 60.4, 0], [0, 30.2, 4.2],
            [-5, 0, 0], [-5, 60.4, 0], [-5, 30.2, 4.2]
        ],
        faces=[
            [0, 1, 2], [3, 4, 5], [0, 1, 4, 3], [1, 2, 5, 4], [2, 0, 3, 5]
        ]
    );

    // Right tip
    translate([5.3, -30.2, -4.2])
    polyhedron(
        points=[
            [0, 0, 0], [0, 60.4, 0], [0, 30.2, 4.2],
            [5, 0, 0], [5, 60.4, 0], [5, 30.2, 4.2]
        ],
        faces=[
            [0, 1, 2], [3, 4, 5], [0, 1, 4, 3], [1, 2, 5, 4], [2, 0, 3, 5]
        ]
    );

    // Left fins
    translate([-10.3, -30.2, -4.2])
    for (i = [0, 1]) {
        translate([0, i * 60.4, 0])
        cube([5, 5, 4.2]);
    }

    // Right fins
    translate([5.3, -30.2, -4.2])
    for (i = [0, 1]) {
        translate([0, i * 60.4, 0])
        cube([5, 5, 4.2]);
    }
}

arrow_indicator();