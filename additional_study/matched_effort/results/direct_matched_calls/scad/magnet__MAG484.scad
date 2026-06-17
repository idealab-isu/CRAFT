$fn = 128;

magnet_d = 20;
magnet_h = 5;
edge_chamfer = 0.6;

module chamfered_cylinder(d=20, h=5, c=0.6) {
    c = min(c, h/2 - 0.001, d/4);
    if (c <= 0) {
        cylinder(d=d, h=h);
    } else {
        union() {
            translate([0,0,c])
                cylinder(d=d, h=h-2*c);
            cylinder(h=c, d1=d-2*c, d2=d);
            translate([0,0,h-c])
                cylinder(h=c, d1=d, d2=d-2*c);
        }
    }
}

chamfered_cylinder(d=magnet_d, h=magnet_h, c=edge_chamfer);