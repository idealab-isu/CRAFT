$fn=64;

module chamfered_block(size=[0.8,0.8,1.2], chamfer=0.06){
    x=size[0]; y=size[1]; z=size[2];
    c=min(chamfer, x/2, y/2, z/2);
    minkowski(){
        cube([x-2*c, y-2*c, z-2*c], center=true);
        octahedron(c);
    }
}

module octahedron(r){
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

chamfered_block([0.8,0.8,1.2], 0.06);