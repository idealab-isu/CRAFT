$fn=96;

module hex_socket(h=2.5, af=2.5) {
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module grub_screw_M5(length=10, d=5, pitch=0.8, thread_depth=0.35, socket_depth=2.5, socket_af=2.5) {
    difference() {
        union() {
            cylinder(h=length, d=d);
            translate([0,0,0])
                cylinder(h=0.8, d1=d-0.6, d2=d);
            translate([0,0,length-0.8])
                cylinder(h=0.8, d1=d, d2=d-0.6);
            linear_extrude(height=length, twist=360*length/pitch, slices=max(ceil(length*12), 60), convexity=10)
                translate([d/2 - thread_depth, 0, 0])
                    circle(r=thread_depth);
        }
        translate([0,0,length - socket_depth])
            hex_socket(h=socket_depth + 0.2, af=socket_af);
    }
}

grub_screw_M5(length=10);