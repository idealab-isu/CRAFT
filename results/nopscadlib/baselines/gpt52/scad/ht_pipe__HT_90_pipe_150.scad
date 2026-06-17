$fn=96;

module ht_pipe_90(d=150, wall=4.5, bend_radius=225, leg=250, socket_len=70, socket_wall=3.5, socket_od_extra=10) {
    od = d;
    id = d - 2*wall;

    socket_od = od + socket_od_extra;
    socket_id = od + 0.6;

    module straight_shell(len, od, id) {
        difference() {
            cylinder(h=len, d=od, center=false);
            translate([0,0,-0.1]) cylinder(h=len+0.2, d=id, center=false);
        }
    }

    module elbow_shell(od, id, R) {
        difference() {
            rotate_extrude(angle=90, convexity=10)
                translate([R,0,0]) circle(d=od);
            rotate_extrude(angle=90, convexity=10)
                translate([R,0,0]) circle(d=id);
        }
    }

    module socket(len, socket_od, socket_id) {
        difference() {
            cylinder(h=len, d=socket_od, center=false);
            translate([0,0,-0.1]) cylinder(h=len+0.2, d=socket_id, center=false);
        }
    }

    union() {
        // Main elbow + legs
        union() {
            // Elbow centered at origin in XY, starting along +X then turning to +Y
            elbow_shell(od, id, bend_radius);

            // Straight leg along +X from elbow start
            translate([bend_radius,0,0])
                rotate([0,90,0])
                    straight_shell(leg, od, id);

            // Straight leg along +Y from elbow end
            translate([0,bend_radius,0])
                rotate([-90,0,0])
                    straight_shell(leg, od, id);
        }

        // Sockets on both ends
        // Socket on +X end
        translate([bend_radius + leg,0,0])
            rotate([0,90,0])
                socket(socket_len, socket_od, socket_id);

        // Socket on +Y end
        translate([0,bend_radius + leg,0])
            rotate([-90,0,0])
                socket(socket_len, socket_od, socket_id);
    }
}

module centered_ht_pipe_90() {
    d=150;
    wall=4.5;
    bend_radius=225;
    leg=250;
    socket_len=70;
    socket_od_extra=10;

    // Compute bounding extents to center the model
    od=d;
    socket_od=od+socket_od_extra;

    x_max = bend_radius + leg + socket_len;
    y_max = bend_radius + leg + socket_len;
    x_min = 0;
    y_min = 0;

    z_min = -socket_od/2;
    z_max = socket_od/2;

    cx = (x_min + x_max)/2;
    cy = (y_min + y_max)/2;
    cz = (z_min + z_max)/2;

    translate([-cx,-cy,-cz])
        ht_pipe_90(d=d, wall=wall, bend_radius=bend_radius, leg=leg, socket_len=socket_len, socket_od_extra=socket_od_extra);
}

centered_ht_pipe_90();