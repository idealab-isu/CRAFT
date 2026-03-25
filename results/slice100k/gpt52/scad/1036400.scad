$fn=128;

od = 6.3;
h  = 25.7;
wall = 1.0;
id = od - 2*wall;

module sleeve(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

sleeve(od, id, h);