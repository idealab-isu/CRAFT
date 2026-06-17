$fn=64;

bbox = [0.1,0.1,0.1];

module hex_prism(flat_d=0.03, h=0.12){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=true);
}

module diamond_cutout(size=0.012, depth=0.01){
    linear_extrude(height=depth, center=false, convexity=10)
        rotate(45)
            square([size, size], center=true);
}

module hub_body(){
    flange_d = 0.09;
    flange_t = 0.02;

    body_d1 = 0.05;
    body_h1 = 0.055;

    body_d2 = 0.04;
    body_h2 = 0.025;

    collar_d = 0.048;
    collar_h = 0.01;

    union(){
        translate([0,0,-0.05 + flange_t/2])
            cylinder(h=flange_t, d=flange_d, center=true);

        translate([0,0,-0.05 + flange_t + body_h1/2])
            cylinder(h=body_h1, d=body_d1, center=true);

        translate([0,0,-0.05 + flange_t + body_h1 + body_h2/2])
            cylinder(h=body_h2, d=body_d2, center=true);

        translate([0,0,-0.05 + flange_t + body_h1 + body_h2 + collar_h/2])
            cylinder(h=collar_h, d=collar_d, center=true);
    }
}

module part(){
    difference(){
        hub_body();

        hex_flat = 0.03;
        translate([0,0,0])
            hex_prism(flat_d=hex_flat, h=0.14);

        flange_t = 0.02;
        z0 = -0.05;
        recess_depth = 0.01;
        recess_size = 0.012;
        rpos = 0.03;

        for(i=[0:3]){
            rotate([0,0,i*90])
                translate([rpos,0,z0])
                    diamond_cutout(size=recess_size, depth=recess_depth);
        }
    }
}

intersection(){
    part();
    cube(bbox, center=true);
}