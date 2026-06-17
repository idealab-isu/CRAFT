module truncated_prism() {
    // Define the top and bottom polygon vertices
    top_vertices = [
        [19.7, 18.85], [-19.7, 18.85], [-19.7, -18.85], [19.7, -18.85]
    ];
    bottom_vertices = [
        [15, 14.5], [-15, 14.5], [-15, -14.5], [15, -14.5]
    ];
    
    // Define the height of the prism
    height = 36.4;
    
    // Create the truncated prism using polyhedron
    polyhedron(
        points = [
            [19.7, 18.85, height/2], [-19.7, 18.85, height/2], [-19.7, -18.85, height/2], [19.7, -18.85, height/2],
            [15, 14.5, -height/2], [-15, 14.5, -height/2], [-15, -14.5, -height/2], [15, -14.5, -height/2]
        ],
        faces = [
            [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7],
            [0, 1, 2, 3], [4, 5, 6, 7]
        ]
    );
}

truncated_prism();