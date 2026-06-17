$fn = 180;

// Parameters (mm)
cap_OD = 132;              // outer diameter
cap_length = 70;           // overall length
wall_t = 3.2;              // wall thickness
end_thickness = 4;         // closed-end thickness
cavity_ID = 125.6;         // socket inner diameter (pipe OD clearance)
insertion_depth = 45;      // depth of socket from open end
stop_thickness = 3;        // axial thickness of internal stop ring
stop_ring_radial = 3.2;    // radial width of stop ring (reduces ID locally)
chamfer = 1.5;             // lead-in chamfer at open end
overlap = 0.6;             // boolean overlap to avoid coincident faces

// Derived
cap_OR = cap_OD/2;
cap_IR = cap_OR - wall_t;

// Z=0 at closed end outer face, +Z toward open end
module ht125_cap() {
    // Ensure valid geometry
    socket_start_z = cap_length - insertion_depth;                 // bottom of socket (toward closed end)
    socket_start_z = max(socket_start_z, end_thickness);           // never cut through closed end
    socket_h = cap_length - socket_start_z;                        // socket depth
    stop_z = socket_start_z;                                       // stop ring located at socket bottom

    difference() {
        // Outer body (single connected solid)
        cylinder(h=cap_length, r=cap_OR, center=false);

        // Inner socket cavity from open end down to socket_start_z
        translate([0, 0, socket_start_z])
            cylinder(h=socket_h + overlap, r=cavity_ID/2, center=false);

        // Internal stop ring: locally smaller ID at socket bottom
        translate([0, 0, stop_z])
            cylinder(h=stop_thickness + overlap, r=(cavity_ID/2 - stop_ring_radial), center=false);

        // Lead-in chamfer at open end (inside)
        translate([0, 0, cap_length - chamfer])
            cylinder(h=chamfer + overlap, r1=cavity_ID/2 + chamfer, r2=cavity_ID/2, center=false);
    }
}

ht125_cap();