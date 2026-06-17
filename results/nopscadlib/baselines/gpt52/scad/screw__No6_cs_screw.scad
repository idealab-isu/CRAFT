$fn=96;

shaft_d = 3.5;
head_d = 7.0;
length = 10.0;

head_h = 3.0;
shaft_h = length - head_h;

module screw_shaft(d, h){
    cylinder(d=d, h=h, center=false);
}

module screw_head(d, h){
    cylinder(d=d, h=h, center=false);
}

union(){
    translate([0,0,-length/2])
        screw_shaft(shaft_d, shaft_h);
    translate([0,0,-length/2 + shaft_h])
        screw_head(head_d, head_h);
}