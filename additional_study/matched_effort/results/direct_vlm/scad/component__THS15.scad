$fn=96;

// Generic "component": a small mounting block with rounded corners,
// two through-holes, and a shallow top pocket.

module rounded_block(size=[60,30,12], r=4){
    x=size[0]; y=size[1]; z=size[2];
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r);
    }
}

module component(){
    base=[60,30,12];
    r=4;

    hole_d=5;
    hole_spacing=36; // center-to-center along X
    hole_y=0;

    pocket=[44,18,3]; // x,y,depth
    pocket_r=2;

    difference(){
        // Body
        translate([0,0,0])
            rounded_block(base, r);

        // Through holes
        for (sx=[-1,1])
            translate([sx*hole_spacing/2, hole_y, -0.5])
                cylinder(h=base[2]+1, d=hole_d);

        // Top pocket
        translate([0,0,base[2]-pocket[2]])
            linear_extrude(height=pocket[2]+0.2)
                offset(r=pocket_r)
                    square([pocket[0]-2*pocket_r, pocket[1]-2*pocket_r], center=true);

        // Small chamfer on bottom edges (simple bevel via subtracting a larger offset)
        translate([0,0,-0.01])
            linear_extrude(height=1.2)
                offset(delta=1.0)
                    offset(delta=-1.0)
                        square([base[0], base[1]], center=true);
    }
}

component();