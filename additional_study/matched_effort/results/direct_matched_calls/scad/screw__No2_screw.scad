$fn = 96;

d_shaft = 2.2;
len = 10;

d_head = 4.2;
h_head = 1.7;

// Simple pan head profile parameters
h_cyl = 0.9;                 // cylindrical portion of head
h_dome = h_head - h_cyl;      // domed portion
d_top = d_head * 0.92;        // slightly smaller top diameter for dome

module pan_head_screw(d_shaft=2.2, len=10, d_head=4.2, h_head=1.7) {
    union() {
        // Shaft
        cylinder(d=d_shaft, h=len);

        // Head (pan)
        translate([0,0,len]) {
            union() {
                // Cylindrical skirt
                cylinder(d=d_head, h=h_cyl);

                // Domed top (frustum)
                translate([0,0,h_cyl])
                    cylinder(d1=d_head, d2=d_top, h=h_dome);
            }
        }
    }
}

pan_head_screw(d_shaft, len, d_head, h_head);