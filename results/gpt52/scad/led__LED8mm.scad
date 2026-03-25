$fn=64;

led_d = 8.0;
led_r = led_d/2;
body_h = 9.2;

flange_d = 9.0;
flange_h = 1.0;

dome_h = 3.0;

lead_d = 0.6;
lead_spacing = 2.54;
lead_len = 12.0;

module lead(x=0, len=lead_len, d=lead_d){
    translate([x,0,-len])
        cylinder(h=len, d=d, center=false);
}

module led_body(){
    union(){
        translate([0,0,flange_h])
            cylinder(h=body_h-flange_h, d=led_d, center=false);
        cylinder(h=flange_h, d=flange_d, center=false);
        translate([0,0,body_h])
            scale([1,1,dome_h/led_r])
                sphere(r=led_r);
    }
}

module led_8mm_th(){
    union(){
        led_body();
        lead(-lead_spacing/2);
        lead( lead_spacing/2);
    }
}

led_8mm_th();