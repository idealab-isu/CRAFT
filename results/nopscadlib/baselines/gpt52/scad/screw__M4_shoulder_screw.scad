$fn=64;

shaft_d = 5.0;
shaft_r = shaft_d/2;
length = 10.0;

head_d = 9.0;
head_r = head_d/2;
head_h = 2.4;

module screw_shaft(d, h){
    cylinder(d=d, h=h, center=false);
}

module screw_head(d, h){
    cylinder(d=d, h=h, center=false);
}

module screw(){
    union(){
        translate([0,0,-length/2])
            screw_shaft(shaft_d, length);
        translate([0,0,length/2 - head_h])
            screw_head(head_d, head_h);
    }
}

screw();