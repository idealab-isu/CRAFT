// HT 90 cap (single connected solid)
// Units: mm

$fn = 120;

// Parameters
ht_pipe_outer_diameter = 50; // OD
ht_pipe_wall_thickness = 3;  // wall
socket_length = 60;          // straight socket length
cap_thickness = 5;           // closed end thickness
internal_stop_depth = 5;     // internal stop ring depth
chamfer_size = 2;            // lead-in chamfer size
overlap = 0.6;               // small overlap to guarantee manifold unions

// Derived
od = ht_pipe_outer_diameter;
id = od - 2*ht_pipe_wall_thickness;
r_od = od/2;
r_id = id/2;

// 90° elbow centerline radius (controls bend size)
elbow_radius = 60;

// ---- Helpers ----
module ring(h, r_outer, r_inner, center=false) {
    difference() {
        cylinder(h=h, r=r_outer, center=center);
        translate([0,0,-overlap]) cylinder(h=h+2*overlap, r=r_inner, center=center);
    }
}

// Quarter torus (solid) around Z axis, lying in XY plane, from +X toward +Y
module quarter_torus_solid(R, r) {
    rotate_extrude(angle=90, convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

// Quarter torus (hollow) for pipe wall
module quarter_torus_pipe(R, r_outer, r_inner) {
    difference() {
        quarter_torus_solid(R, r_outer);
        quarter_torus_solid(R, r_inner);
    }
}

// ---- Main part ----
module ht_90_cap() {

    // Keep elbow centered at origin:
    // - socket axis is +Z at (x=R, y=0)
    // - capped end axis is +X at (x=0, y=R)
    union() {

        // Elbow wall
        quarter_torus_pipe(elbow_radius, r_od, r_id);

        // Socket (open end) along +Z at the elbow start (angle 0° point)
        // Start slightly inside elbow for guaranteed connection.
        translate([elbow_radius, 0, -overlap])
            ring(socket_length + overlap, r_od, r_id);

        // Lead-in chamfer at socket mouth (top end of socket)
        translate([elbow_radius, 0, socket_length - chamfer_size])
        difference() {
            cylinder(h=chamfer_size, r1=r_od, r2=r_od - chamfer_size);
            translate([0,0,-overlap])
                cylinder(h=chamfer_size + 2*overlap,
                         r1=r_id,
                         r2=max(r_id - chamfer_size, 0.01));
        }

        // Internal stop ring inside socket near elbow junction
        // Make it a ring (not a solid plug) so the socket remains open.
        translate([elbow_radius, 0, 0])
            ring(internal_stop_depth, r_id, max(r_id - internal_stop_depth, 0.01));

        // Closed end cap at the other end (along +X at elbow end, angle 90° point)
        // Place cap so its inner face overlaps into the elbow end by 'overlap'.
        translate([-cap_thickness + overlap, elbow_radius, 0])
            rotate([0,90,0])
                cylinder(h=cap_thickness, r=r_od);

        // Seal the bore at the capped end: solid plug that extends into elbow
        // and overlaps into the cap disk.
        translate([-cap_thickness + overlap, elbow_radius, 0])
            rotate([0,90,0])
                cylinder(h=cap_thickness + overlap, r=r_id);
    }
}

ht_90_cap();