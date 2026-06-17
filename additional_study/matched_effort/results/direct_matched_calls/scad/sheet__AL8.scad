$fn = 64;

length = 200;   // mm
width  = 150;   // mm
thick  = 6;     // mm

// Slight edge break to mimic a tooling plate (small chamfer)
chamfer = 0.5;  // mm

module tooling_plate(L, W, T, c){
    c = min(c, min(L, W)/10, T/2);
    if (c <= 0){
        cube([L, W, T], center=false);
    } else {
        minkowski(){
            cube([L-2*c, W-2*c, T-2*c], center=false);
            octahedron(c);
        }
    }
}

module octahedron(r){
    polyhedron(
        points=[
            [ 0, 0,  r],
            [ r, 0,  0],
            [ 0, r,  0],
            [-r, 0,  0],
            [ 0,-r,  0],
            [ 0, 0, -r]
        ],
        faces=[
            [0,1,2],
            [0,2,3],
            [0,3,4],
            [0,4,1],
            [5,2,1],
            [5,3,2],
            [5,4,3],
            [5,1,4]
        ]
    );
}

color([0.75, 0.78, 0.80])
tooling_plate(length, width, thick, chamfer);