$fn=128;

od = 15.0;
id = 10.0;
h  = 82.5;

module tube(od, id, h) {
    difference() {
        cylinder(h=h, d=od, center=true);
        cylinder(h=h+0.2, d=id, center=true);
    }
}

tube(od, id, h);