$fn = 96;

d_shaft = 6.0;
l_shaft = 10.0;

d_head  = 12.0;
h_head  = 6.0;

hex_flat = 5.0;          // approximate for M6 socket
hex_depth = 4.0;         // approximate socket depth
hex_corner = hex_flat / cos(30);

chamfer = 0.6;

module chamfered_cylinder(d, h, c=0.5) {
    // simple top/bottom chamfer via hull of two cylinders
    hull() {
        translate([0,0,0]) cylinder(d=d-2*c, h=0.01);
        translate([0,0,c]) cylinder(d=d, h=h-2*c);
        translate([0,0,h-0.01]) cylinder(d=d-2*c, h=0.01);
    }
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // shaft
            cylinder(d=d_shaft, h=l_shaft);

            // head
            translate([0,0,l_shaft])
                chamfered_cylinder(d=d_head, h=h_head, c=chamfer);
        }

        // hex socket
        translate([0,0,l_shaft + h_head - hex_depth])
            cylinder(r=hex_corner/2, h=hex_depth + 0.2, $fn=6);

        // slight entry chamfer for socket
        translate([0,0,l_shaft + h_head - 0.8])
            cylinder(r1=hex_corner/2 + 0.4, r2=hex_corner/2, h=0.8, $fn=6);
    }
}

socket_head_cap_screw();