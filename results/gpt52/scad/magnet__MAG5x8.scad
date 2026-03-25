$fn=96;

magnet_d = 20;
magnet_h = 5;
edge_chamfer = 0.6;

module chamfered_cylinder(d=20, h=5, c=0.6) {
    c2 = min(c, h/2 - 0.01);
    union() {
        translate([0,0,-h/2 + c2])
            cylinder(d=d, h=h - 2*c2, center=false);
        translate([0,0,-h/2])
            cylinder(d1=d - 2*c2, d2=d, h=c2, center=false);
        translate([0,0,h/2 - c2])
            cylinder(d1=d, d2=d - 2*c2, h=c2, center=false);
    }
}

module magnet(d=20, h=5, c=0.6) {
    chamfered_cylinder(d=d, h=h, c=c);
}

magnet(d=magnet_d, h=magnet_h, c=edge_chamfer);