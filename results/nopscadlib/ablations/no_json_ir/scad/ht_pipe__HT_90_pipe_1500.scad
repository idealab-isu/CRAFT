// HT 90 Pipe (DN90) - 90° elbow with one socket/bell end
// Units: mm

$fn = 128;

// Parameters
outer_diameter      = 110;   // pipe OD
wall_thickness      = 3.2;   // wall thickness

length              = 1500;  // overall centerline length (arc + straights)

bend_angle          = 90;    // degrees
bend_radius         = 250;   // centerline radius of elbow (adjust if needed)

socket_length       = 60;    // bell/socket axial length
socket_od_increase  = 10;    // socket OD increase over pipe OD
socket_wall_extra   = 1.2;   // socket wall extra thickness over pipe wall
stop_ring_length    = 6;     // small external stop ring at socket end
stop_ring_increase  = 2;     // extra OD for stop ring

// Use 1–2mm overlap to guarantee solid connections
overlap = 1.5;

// Derived
pipe_od   = outer_diameter;
pipe_id   = pipe_od - 2*wall_thickness;

socket_od   = pipe_od + socket_od_increase;
socket_wall = wall_thickness + socket_wall_extra;
socket_id   = socket_od - 2*socket_wall;

arc_len = bend_radius * (bend_angle * PI / 180);
straight_total = max(0, length - arc_len);
straight_each  = straight_total / 2;

// Helpers
module hollow_cyl(h, od, id) {
    difference() {
        cylinder(h=h, d=od, center=false);
        translate([0,0,-overlap])
            cylinder(h=h + 2*overlap, d=id, center=false);
    }
}

module hollow_torus_sector(R, angle_deg, od, id) {
    // Sector centered at origin, lying in XY plane, swept around Z
    difference() {
        rotate_extrude(angle=angle_deg, convexity=10)
            translate([R, 0, 0]) circle(d=od);
        rotate_extrude(angle=angle_deg, convexity=10)
            translate([R, 0, 0]) circle(d=id);
    }
}

module ht90_pipe_1500() {
    union() {
        // --- Elbow (reference at origin) ---
        // 90° bend from +X to +Y
        hollow_torus_sector(R=bend_radius, angle_deg=bend_angle, od=pipe_od, id=pipe_id);

        // --- Inlet straight (tangent at elbow start, along +X) ---
        // Elbow start tangent point is at (bend_radius, 0, 0).
        // Place straight so its +X end overlaps into the elbow by 'overlap'.
        translate([bend_radius - (straight_each + overlap), 0, 0])
            rotate([0,90,0])
                hollow_cyl(h=straight_each + overlap, od=pipe_od, id=pipe_id);

        // --- Outlet straight (tangent at elbow end, along +Y) ---
        // FIX: ensure the straight actually intersects the elbow at y=bend_radius.
        // Cylinder axis is +Z before rotation; after rotate([-90,0,0]) it becomes +Y.
        // Therefore the base must start at y = bend_radius - overlap (not bend_radius - overlap with a Z-offset).
        translate([0, bend_radius - overlap, 0])
            rotate([-90,0,0])
                hollow_cyl(h=straight_each + overlap, od=pipe_od, id=pipe_id);

        // --- Socket/bell on outlet end (overlaps into outlet straight) ---
        // Outlet straight ends at y = bend_radius + straight_each.
        translate([0, bend_radius + straight_each - overlap, 0])
            rotate([-90,0,0])
                hollow_cyl(h=socket_length + overlap, od=socket_od, id=socket_id);

        // --- External stop ring at very end of socket (overlap into socket) ---
        // Socket ends at y = bend_radius + straight_each + socket_length.
        translate([0, bend_radius + straight_each + socket_length - stop_ring_length - overlap, 0])
            rotate([-90,0,0])
                cylinder(h=stop_ring_length + overlap,
                         d=socket_od + stop_ring_increase,
                         center=false);
    }
}

ht90_pipe_1500();