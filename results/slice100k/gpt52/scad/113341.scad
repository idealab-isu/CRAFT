$fn=64;

L = 60.4;
W = 20.6;
H = 8.4;

tip_len = 12.0;
body_len = L - 2*tip_len;

fin_len = 6.0;
fin_out = 3.2;
fin_h1 = 2.2;
fin_h2 = 3.6;
fin_z1 = 0.0;
fin_z2 = H - fin_h2;

module arrow_tip(len, w, h){
    polyhedron(
        points=[
            [0, -w/2, 0],
            [0,  w/2, 0],
            [0,  w/2, h],
            [0, -w/2, h],
            [len, 0, 0],
            [len, 0, h]
        ],
        faces=[
            [0,1,2,3],
            [0,4,1],
            [0,3,5,4],
            [1,4,5,2],
            [3,2,5],
            [0,4,5,3]
        ]
    );
}

module fin_step(side=1){
    union(){
        translate([0, side*(W/2), fin_z1])
            cube([fin_len, fin_out, fin_h1], center=false);
        translate([0, side*(W/2), fin_z2])
            cube([fin_len, fin_out, fin_h2], center=false);
    }
}

module end_fins(x0){
    translate([x0,0,0]){
        fin_step(1);
        fin_step(-1);
    }
}

module indicator(){
    union(){
        translate([-body_len/2, -W/2, 0])
            cube([body_len, W, H], center=false);

        translate([body_len/2, 0, 0])
            arrow_tip(tip_len, W, H);

        mirror([1,0,0])
            translate([body_len/2, 0, 0])
                arrow_tip(tip_len, W, H);

        end_fins(body_len/2 - fin_len - 1.2);
        mirror([1,0,0]) end_fins(body_len/2 - fin_len - 1.2);
    }
}

translate([0,0,-H/2]) indicator();