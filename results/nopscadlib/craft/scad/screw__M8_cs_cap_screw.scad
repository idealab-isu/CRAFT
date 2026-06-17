// Socket head cap screw (simplified, one connected solid)
// Requested: 8.0mm shank diameter, 16.0mm head diameter, 10mm under-head length

shaft_diameter = 8;          //[4:16:0.1]
length = 10;                 //[5:30:0.1]   // under-head length
head_diameter = 16;          //[8:32:0.1]
head_height = 8;             //[4:16:0.1]
socket_af = 6;               //[3:12:0.1]   // hex across flats
socket_depth = 4;            //[2:8:0.1]
thread_length = 8;           //[0:20:0.1]   // visual only (no helical thread)
thread_minor_diameter = 7.2; //[3.6:14.4:0.1]
tip_length = 1.2;            //[0.2:3:0.1]  // conical tip length
overlap = 0.2;               //[0.05:1:0.05]
$fn = 128;

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h) {
    R = (af/2) / cos(30); // circumradius from across-flats
    cylinder(h=h, r=R, center=true, $fn=6);
}

module socket_head_cap_screw() {
    shank_r = shaft_diameter/2;
    head_r  = head_diameter/2;

    // Clamp dependent lengths so everything stays connected and within the shank length
    tlen = min(thread_length, max(0, length));
    tipl = min(tip_length, max(0, length));
    // Ensure the "threaded" section doesn't extend into the conical tip region
    tlen_eff = max(0, min(tlen, length - tipl));

    // Coordinate system:
    // Under-head plane at z=0
    // Head spans z=[0, head_height]
    // Shank spans z=[-length, 0]
    difference() {
        union() {
            // Head (cylindrical)
            translate([0, 0, head_height/2])
                cylinder(h=head_height + overlap, r=head_r, center=true);

            // Shank major diameter (unthreaded portion)
            translate([0, 0, -length/2])
                cylinder(h=length + overlap, r=shank_r, center=true);

            // Visual "threaded" portion as a minor-diameter sleeve near the tip (still connected)
            if (tlen_eff > 0)
                translate([0, 0, -length + tipl + tlen_eff/2])
                    cylinder(h=tlen_eff + overlap, r=thread_minor_diameter/2, center=true);

            // Screw tip (conical), connected to shank at z = -length + tipl
            if (tipl > 0)
                translate([0, 0, -length + tipl/2])
                    cylinder(h=tipl + overlap, r1=thread_minor_diameter/2, r2=0.01, center=true);
        }

        // Internal hex socket recess (subtracted from head)
        // Top face at z=head_height, recess goes down by socket_depth
        translate([0, 0, head_height - socket_depth/2])
            hex_prism_af(socket_af, socket_depth + 2*overlap);
    }
}

socket_head_cap_screw();