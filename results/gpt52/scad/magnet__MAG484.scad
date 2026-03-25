$fn=96;

magnet_d = 20;
magnet_h = 5;
edge_chamfer = 0.6;

module chamfered_cylinder(d=20, h=5, c=0.6) {
    union() {
        translate([0,0,-h/2 + c/2])
            cylinder(d=d-2*c, h=h-c, center=true);
        translate([0,0, h/2 - c/2])
            cylinder(d1=d-2*c, d2=d, h=c, center=true);
        translate([0,0,-h/2 + c/2])
            cylinder(d1=d, d2=d-2*c, h=c, center=true);
    }
}

module magnet(d=20, h=5, c=0.6) {
    chamfered_cylinder(d=d, h=h, c=c);
}

magnet(d=magnet_d, h=magnet_h, c=edge_chamfer);