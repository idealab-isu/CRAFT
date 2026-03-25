$fn = 128;

// Parameters (HT straight pipe)
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 1500; //[750:3000:10]          // total straight length
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]

// Optional socket end fitting(s)
include_end_fitting = 1; //[0:1:1]
end_fitting_count = 1; //[0:2:1]           // 0,1,2 sockets
fitting_length_mm = 55; //[30:110:1]
fitting_over_od_mm = 6; //[3:12:0.5]
fitting_overlap_mm = 1; //[0.5:2:0.1]

// Derived radii
od_r = nominal_diameter_mm/2;
id_r = max(0.01, od_r - pipe_wall_mm);

socket_od_r = od_r + fitting_over_od_mm/2;
socket_id_r = id_r;

// Small overlap to guarantee manifold unions
eps = 0.5;

// Straight hollow pipe along +X, starting at x=0
module straight_pipe_x(len, outer_r, inner_r) {
    difference() {
        translate([len/2, 0, 0]) rotate([0,90,0]) cylinder(h=len, r=outer_r, center=true);
        translate([len/2, 0, 0]) rotate([0,90,0]) cylinder(h=len + 2*eps, r=inner_r, center=true);
    }
}

// Socket along +X, starting at x=0
module socket_x(len, outer_r, inner_r) {
    difference() {
        translate([len/2, 0, 0]) rotate([0,90,0]) cylinder(h=len, r=outer_r, center=true);
        translate([len/2, 0, 0]) rotate([0,90,0]) cylinder(h=len + 2*eps, r=inner_r, center=true);
    }
}

// Main HT straight pipe (one connected solid)
module ht_straight_pipe() {
    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe body: exact length_mm
        straight_pipe_x(length_mm, od_r, id_r);

        // End fittings (sockets), connected with calculated placement + overlap
        if (include_end_fitting && end_fitting_count > 0) {
            // Socket on left end (x=0), extends outward to -X
            translate([-fitting_length_mm + fitting_overlap_mm, 0, 0])
                socket_x(fitting_length_mm, socket_od_r, socket_id_r);
        }
        if (include_end_fitting && end_fitting_count > 1) {
            // Socket on right end (x=length_mm), extends outward to +X
            translate([length_mm - fitting_overlap_mm, 0, 0])
                socket_x(fitting_length_mm, socket_od_r, socket_id_r);
        }
    }
}

ht_straight_pipe();