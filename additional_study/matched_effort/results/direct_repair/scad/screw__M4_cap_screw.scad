$fn=96;

// Socket Head Cap Screw (approx. ISO 4762)
// Parameters from prompt:
d_shank = 4.0;      // mm (nominal thread/shank diameter)
L = 10.0;           // mm (under-head length)
d_head = 7.0;       // mm
h_head = 4.0;       // mm

// Typical socket dimensions for M4 SHCS (approx):
socket_af = 3.0;    // mm hex key size
socket_depth = 2.2; // mm
socket_chamfer = 0.3;

// Simple thread approximation (smooth cylinder)
module shank(d, len){
    cylinder(d=d, h=len);
}

module head(d, h){
    // slight top edge chamfer
    difference(){
        union(){
            cylinder(d=d, h=h - 0.2);
            translate([0,0,h - 0.2])
                cylinder(d1=d, d2=d - 0.4, h=0.2);
        }
        // hex socket
        translate([0,0,h - socket_depth])
            cylinder(d=socket_af / cos(30), h=socket_depth + 0.01, $fn=6);
        // small chamfer at socket opening
        translate([0,0,h - socket_chamfer])
            cylinder(d1=(socket_af / cos(30)) + 0.6, d2=(socket_af / cos(30)), h=socket_chamfer + 0.01, $fn=6);
    }
}

module socket_head_cap_screw(){
    union(){
        // shank under head
        shank(d_shank, L);
        // head on top of shank
        translate([0,0,L])
            head(d_head, h_head);
    }
}

socket_head_cap_screw();