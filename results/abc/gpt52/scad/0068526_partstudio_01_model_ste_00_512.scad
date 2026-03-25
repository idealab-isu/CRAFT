$fn=64;

L = 80;
W = 40;
H = 30;

wall = 6;
floor_t = 6;

inner_taper = 2;      // total widening from bottom to top on each inner wall face
chamfer = 2;

relief_w = 22;
relief_h = 10;
relief_len = 60;

module chamfered_block(size=[10,10,10], c=1) {
    x=size[0]; y=size[1]; z=size[2];
    c2 = min(c, min(x,y)/2);
    linear_extrude(height=z)
        polygon(points=[
            [0,0],
            [x,0],
            [x,y-c2],
            [x-c2,y],
            [c2,y],
            [0,y-c2]
        ]);
}

module u_channel() {
    difference() {
        translate([-L/2, -W/2, 0])
            chamfered_block([L,W,H], chamfer);

        // Open-top cavity with tapered inner faces
        translate([-L/2 + wall, -W/2 + wall, floor_t])
            linear_extrude(height=H - floor_t + 0.2, scale=[(L-2*wall + 2*inner_taper)/(L-2*wall), (W-2*wall + 2*inner_taper)/(W-2*wall)])
                square([L-2*wall, W-2*wall], center=false);

        // Bottom relief/notch to create bridge-like profile
        translate([-relief_len/2, -relief_w/2, -0.1])
            cube([relief_len, relief_w, relief_h + 0.2], center=false);
    }
}

u_channel();