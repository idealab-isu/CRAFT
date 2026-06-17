$fn=64;

size = 0.1;
chamfer = 0.02;

module chamfered_cube(s=0.1, c=0.02) {
    c2 = min(c, s/2);
    intersection() {
        cube([s,s,s], center=true);
        minkowski() {
            cube([s-2*c2, s-2*c2, s-2*c2], center=true);
            octahedron(c2);
        }
    }
}

module octahedron(r=1) {
    polyhedron(
        points=[
            [ r, 0, 0],
            [-r, 0, 0],
            [ 0, r, 0],
            [ 0,-r, 0],
            [ 0, 0, r],
            [ 0, 0,-r]
        ],
        faces=[
            [0,2,4],
            [2,1,4],
            [1,3,4],
            [3,0,4],
            [2,0,5],
            [1,2,5],
            [3,1,5],
            [0,3,5]
        ]
    );
}

chamfered_cube(size, chamfer);