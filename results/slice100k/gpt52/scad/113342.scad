$fn=64;

L = 72.4;
Wmax = 10.3;
Wmin = 7.2;
Tmax = 6.0;
Tmin = 4.2;

fin_len = 18.0;
fin_height = 12.0;
fin_thick = 2.2;
fin_angle = 55;

module tapered_arm(len=L, w1=Wmax, w2=Wmin, t1=Tmax, t2=Tmin){
    hull(){
        translate([0,0,-len/2])
            cube([w1,t1,0.01], center=true);
        translate([0,0, len/2])
            cube([w2,t2,0.01], center=true);
    }
}

module triangular_fin(len=fin_len, height=fin_height, thick=fin_thick){
    linear_extrude(height=thick, center=true, convexity=10)
        polygon(points=[
            [0,0],
            [len,0],
            [0,height]
        ]);
}

module part(){
    union(){
        tapered_arm();

        translate([0,0,-L/2 + 14])
            rotate([0,fin_angle,0])
                translate([Wmax/2 - 0.6, 0, 0])
                    rotate([0,0,90])
                        triangular_fin();
    }
}

part();