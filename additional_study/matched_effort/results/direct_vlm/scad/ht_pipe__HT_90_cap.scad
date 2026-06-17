$fn = 180;

// HT 90 cap (end cap) - parametric approximation
// Units: mm

// -------- Parameters --------
dn = 90;                 // nominal diameter
wall = 3.2;              // wall thickness
cap_depth = 55;          // overall cap depth (Z)
socket_depth = 40;       // insertion/socket depth from opening
lip_thickness = 4;       // closed-end thickness

outer_clearance = 0.6;   // small extra on OD for visual realism
inner_clearance = 0.4;   // small extra on ID for fit allowance (visual)

// Details
lead_in = 2.0;           // lead-in chamfer height at opening
outer_flare = 1.5;       // OD flare amount at opening
inner_lead = 1.6;        // ID lead-in amount at opening

rim_bead_rad = 1.2;      // bead radius (torus-like)
rim_bead_z = 0.9;        // bead center height above opening plane

// Extra cap features (to make orthographic views show details)
outer_step_h = 6.0;      // outer "bell" height at opening
outer_step_extra = 3.0;  // extra OD for bell section
top_dome = 1.2;          // slight convex top (closed end) height

// -------- Derived --------
od_pipe   = dn + outer_clearance;                 // pipe OD (visual)
id_socket = dn - 2*wall + inner_clearance;        // socket bore ID (visual)

cap_od = od_pipe + 6;                             // main cap outer diameter
cap_id = cap_od - 2*wall;                         // main cavity ID (above socket step)

bell_od = cap_od + outer_step_extra;              // bell OD at opening

socket_depth_  = min(socket_depth, cap_depth - lip_thickness - 0.8);
socket_depth__ = max(8, socket_depth_);
lip_thickness_ = min(lip_thickness, cap_depth - 2);

step_h = 2.0;                                     // transition height between socket and main cavity
step_h_ = min(step_h, max(1.2, cap_depth - lip_thickness_ - socket_depth__ - 0.2));

outer_step_h_ = min(outer_step_h, max(2.0, socket_depth__ - lead_in - 0.5));

eps = 0.02;

// -------- Helpers --------
module frustum(h, d1, d2) {
    cylinder(h=h, d1=d1, d2=d2);
}

module bead_ring(d_outer, bead_rad) {
    rotate_extrude(convexity=10)
        translate([d_outer/2 - bead_rad, 0, 0])
            circle(r=bead_rad, $fn=96);
}

// -------- Model --------
module ht90_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(h=cap_depth, d=cap_od);

            // Outer bell/step at opening (socket/bell end)
            // Connected: starts at z=0 and overlaps main body
            cylinder(h=outer_step_h_, d=bell_od);

            // Outer flare/chamfer at opening edge
            frustum(lead_in, bell_od + outer_flare, bell_od);

            // Outer rim bead near opening
            translate([0, 0, rim_bead_z])
                bead_ring(bell_od + outer_flare, rim_bead_rad);

            // Slight convex closed end (top dome) to avoid "flat can" look
            // Connected: sits on top face at z=cap_depth
            translate([0, 0, cap_depth - eps])
                scale([1, 1, top_dome / (cap_od/2)])
                    sphere(r=cap_od/2);
        }

        // Hollow interior (open at z=0, closed at z=cap_depth)
        // Main cavity above socket step
        translate([0, 0, socket_depth__ + step_h_])
            cylinder(
                h = (cap_depth - lip_thickness_) - (socket_depth__ + step_h_) + eps,
                d = cap_id
            );

        // Socket bore (insertion region)
        translate([0, 0, 0])
            cylinder(h=socket_depth__ + eps, d=id_socket);

        // Transition/relief step between socket and main cavity (slight taper)
        translate([0, 0, socket_depth__ - eps])
            frustum(step_h_ + 2*eps, id_socket, cap_id);

        // Inner lead-in chamfer at opening (makes opening visible in views)
        translate([0, 0, 0])
            frustum(lead_in, id_socket + 2*inner_lead, id_socket);

        // NOTE: Closed end thickness is ensured by stopping cavities at cap_depth - lip_thickness_
    }
}

ht90_cap();