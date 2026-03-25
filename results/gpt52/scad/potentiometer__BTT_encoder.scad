$fn=64;

dims = [12, 11, 6, 0.5]; // [body_x, body_y, body_z, pin_d]

body_x = dims[0];
body_y = dims[1];
body_z = dims[2];
pin_d  = dims[3];

module pin(len=4, d=0.5){
    translate([0,0,-len/2])
        cylinder(h=len, d=d, center=true);
}

module potentiometer(body_x=12, body_y=11, body_z=6, pin_d=0.5){
    shaft_d = min(body_x, body_y)*0.35;
    shaft_h = body_z*0.8;
    collar_d = shaft_d*1.35;
    collar_h = body_z*0.15;

    lug_len = body_x*0.25;
    lug_w   = body_y*0.18;
    lug_t   = body_z*0.12;

    pin_len = body_z*0.9;

    union(){
        translate([0,0,0])
            cube([body_x, body_y, body_z], center=true);

        translate([0,0, body_z/2 + collar_h/2])
            cylinder(h=collar_h, d=collar_d, center=true);

        translate([0,0, body_z/2 + collar_h + shaft_h/2])
            cylinder(h=shaft_h, d=shaft_d, center=true);

        translate([0,0,-body_z/2 - lug_t/2])
            cube([lug_len, lug_w, lug_t], center=true);

        pin_spacing = body_x*0.25;
        for(i=[-1,0,1]){
            translate([i*pin_spacing, 0, -body_z/2 - lug_t - pin_len/2])
                pin(len=pin_len, d=pin_d);
        }
    }
}

potentiometer(body_x, body_y, body_z, pin_d);