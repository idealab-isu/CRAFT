$fn=64;

outer = [0.8, 0.3, 0.3];
wall = 0.05;

module rect_tube(outer_size=[1,1,1], wall_th=0.1){
    inner_size = [outer_size[0], outer_size[1]-2*wall_th, outer_size[2]-2*wall_th];
    difference(){
        cube(outer_size, center=true);
        cube(inner_size, center=true);
    }
}

rect_tube(outer, wall);