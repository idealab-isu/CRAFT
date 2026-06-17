module tapered_wedge() {
    difference() {
        // Main wedge shape
        polyhedron(
            points=[
                [0, 0, 0],        // Point 0
                [36.2, 0, 0],     // Point 1
                [36.2, 55.5, 0],  // Point 2
                [0, 55.5, 8.7],   // Point 3
                [36.2, 0, 8.7],   // Point 4
                [36.2, 55.5, 8.7] // Point 5
            ],
            faces=[
                [0, 1, 4, 3],     // Bottom face
                [1, 2, 5, 4],     // Side face
                [2, 3, 5],        // Top face
                [0, 3, 2, 1],     // Back face
                [3, 4, 5]         // Front face
            ]
        );

        // Create the step/flange
        translate([0, 0, 8.7])
        cube([36.2, 5, 1]);
    }
}

translate([-18.1, -27.75, -4.35])
tapered_wedge();