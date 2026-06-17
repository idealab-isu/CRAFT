$fn=96;

module hex_socket(h=3, af=3, center=false){
    r = af/(2*cos(30));
    translate([0,0, center ? -h/2 : 0])
        linear_extrude(height=h, center=false)
            polygon(points=[
                [ r, 0],
                [ r*cos(60),  r*sin(60)],
                [-r*cos(60),  r*sin(60)],
                [-r, 0],
                [-r*cos(60), -r*sin(60)],
                [ r*cos(60), -r*sin(60)]
            ]);
}

module m6_grub(length=12, major_d=6, pitch=1, socket_af=3, socket_depth=3, chamfer=0.6){
    minor_d = major_d - 1.226869*pitch; // approx ISO metric external thread minor diameter
    thread_h = 0.61343*pitch;          // radial thread height
    turns = length/pitch;

    difference(){
        union(){
            // Threaded body (approximate helical thread)
            union(){
                cylinder(h=length, d=minor_d, center=true);

                linear_extrude(height=length, center=true, twist=turns*360, slices=max(ceil(turns*24), 60), convexity=10)
                    translate([minor_d/2, 0, 0])
                        polygon(points=[
                            [0, -pitch*0.30],
                            [thread_h, 0],
                            [0,  pitch*0.30]
                        ]);
            }

            // End chamfers
            translate([0,0, length/2])
                cylinder(h=chamfer, d1=major_d, d2=major_d-2*chamfer, center=false);
            translate([0,0, -length/2 - chamfer])
                cylinder(h=chamfer, d1=major_d-2*chamfer, d2=major_d, center=false);
        }

        // Hex socket
        translate([0,0, length/2 - socket_depth])
            hex_socket(h=socket_depth+0.2, af=socket_af, center=false);
    }
}

m6_grub(length=12, major_d=6, pitch=1, socket_af=3, socket_depth=3, chamfer=0.6);