$fn=96;

module hex_socket(h=2.2, af=2.0){
    r = af/(2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module grub_screw_M4(L=6, d=4, pitch=0.7, socket_depth=2.2, socket_af=2.0){
    union(){
        difference(){
            cylinder(h=L, d=d);
            translate([0,0,L-socket_depth])
                hex_socket(h=socket_depth+0.2, af=socket_af);
        }
        translate([0,0,0])
            cylinder(h=0.8, d1=d*0.95, d2=0.6);
        translate([0,0,0.8])
            cylinder(h=L-0.8, d=d*0.98);
    }
}

translate([0,0,-3])
    grub_screw_M4(L=6);