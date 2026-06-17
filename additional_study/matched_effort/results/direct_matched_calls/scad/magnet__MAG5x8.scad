$fn = 128;

magnet_d = 20;
magnet_h = 5;
edge_chamfer = 0.6;

module chamfered_cylinder(d=20, h=5, c=0.6) {
    c = min(c, h/2, d/4);
    union() {
        translate([0,0,c])
            cylinder(d=d, h=h-2*c);
        cylinder(d1=d-2*c, d2=d, h=c);
        translate([0,0,h-c])
            cylinder(d1=d, d2=d-2*c, h=c);
    }
}

chamfered_cylinder(d=magnet_d, h=magnet_h, c=edge_chamfer);