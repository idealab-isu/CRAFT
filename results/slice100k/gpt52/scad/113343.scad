$fn=64;

L = 55.5;
W = 36.2;
H = 8.7;

step_w = 4.0;
step_h = 1.6;

end_lip_len = 6.0;
end_lip_h = 2.2;

module tapered_wedge(len=L, width=W, height=H){
    polyhedron(
        points=[
            [-width/2, -len/2, 0],
            [ width/2, -len/2, 0],
            [ 0,        len/2, 0],
            [-width/2, -len/2, height],
            [ width/2, -len/2, height],
            [ 0,        len/2, 0]
        ],
        faces=[
            [0,1,2],
            [3,5,4],
            [0,2,5,3],
            [1,4,5,2],
            [0,3,4,1]
        ],
        convexity=10
    );
}

module side_step(len=L, width=W, height=H, sw=step_w, sh=step_h){
    translate([-(width/2 - sw/2), 0, height - sh/2])
        cube([sw, len, sh], center=true);
}

module end_lip(width=W, len=L, lip_len=end_lip_len, lip_h=end_lip_h){
    translate([0, -len/2 + lip_len/2, lip_h/2])
        cube([width, lip_len, lip_h], center=true);
}

union(){
    tapered_wedge();
    side_step();
    end_lip();
}