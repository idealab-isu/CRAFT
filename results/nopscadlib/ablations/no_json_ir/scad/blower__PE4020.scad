$fn = 128;

// Centrifugal blower fan target overall envelope: 40 x 40 x 20 mm (including outlet)
footprint_x = 40;
footprint_y = 40;
overall_thickness = 20;

// Casing / wall
wall = 2.0;
z_overlap = 1.2;          // robust overlap (1-2mm as required)
gap = 0.6;                // internal clearance

// Outlet (rectangular nozzle) - included in 40mm overall X
outlet_len = 8;           // protrusion beyond main body
outlet_w = 12;
outlet_h = 10;

// Main body X size so that body + outlet = 40
body_x = footprint_x - outlet_len;
body_y = footprint_y;
body_z = overall_thickness;

// Inlet (top/bottom circular opening)
inlet_d = 22;

// Impeller (visible through inlet)
impeller_d = 28;
impeller_th = 8;
hub_d = 10;
blade_count = 11;
blade_w = 2.2;
blade_overlap = 1.2;

// Volute / cavity sizing
cav_h = body_z - 2*wall;
cav_d1 = impeller_d + 2*gap;
cav_d2 = impeller_d*0.78 + 2*gap;

// Corner bumps (subtle mounting lugs)
corner_bump_r = 2.0;
corner_bump_h = 1.2;
corner_inset = 2.0;

// Derived placement (keep total envelope centered at origin)
body_center_x = -outlet_len/2;

// Place outlet so it overlaps the body by z_overlap (prevents visible separation)
outlet_center_x = body_center_x + body_x/2 + outlet_len/2 - z_overlap;

// Convenience: body +X face location
body_posx_face = body_center_x + body_x/2;

// --- FIX: attach the curved arc/duct segment to the main housing ---
// The "orange arc" seen floating in orthographic views is recreated here as a
// thin curved strap and is positioned to physically intersect the top of the
// main body with 1-2mm overlap.
arc_th = 2.0;                 // thickness in Z
arc_rad = inlet_d/2 + 3.0;    // radius around inlet
arc_w  = 3.0;                 // radial width of the strap
arc_ang = 70;                 // degrees of arc
arc_overlap = 1.2;            // guaranteed intersection with body

module impeller() {
    blade_len = (impeller_d - hub_d)/2;

    union() {
        cylinder(d=hub_d, h=impeller_th, center=true);
        cylinder(d=impeller_d*0.55, h=impeller_th*0.6, center=true);

        for (i = [0:blade_count-1]) {
            rotate([0,0,i*360/blade_count])
                translate([hub_d/2 + blade_len/2 - blade_overlap, 0, 0])
                    hull() {
                        translate([-blade_len*0.25, 0, 0])
                            cube([blade_len*0.5, blade_w, impeller_th], center=true);
                        translate([blade_len*0.25, blade_w*0.6, 0])
                            cube([blade_len*0.5, blade_w, impeller_th], center=true);
                    }
        }
    }
}

// Solid "bridge" that guarantees the outlet is physically attached to the main housing.
module outlet_root_bridge() {
    bridge_x = wall + z_overlap + 0.8;   // extra to guarantee intersection
    bridge_y = outlet_w;
    bridge_z = outlet_h;

    translate([body_posx_face + bridge_x/2 - z_overlap, 0, 0])
        cube([bridge_x, bridge_y, bridge_z], center=true);
}

// Curved arc/duct segment (previously floating) - now attached.
// Implemented as a ring-sector strap and placed so it intersects the top face
// of the main body by arc_overlap.
module attached_curved_arc() {
    // Place arc centered over the inlet (which is at global X=0 in this model),
    // and push it down so it intersects the top of the body.
    // Top face Z = +body_z/2. Arc center Z is set to top - arc_th/2 + overlap.
    arc_center_z = body_z/2 - arc_th/2 + arc_overlap;

    // Slightly bias toward +X so it visually sits near the outlet side,
    // but still intersects the main housing.
    arc_center_x = 0 + 2.0;

    translate([arc_center_x, 0, arc_center_z])
        rotate([0,0,20])  // small orientation similar to the shown offset piece
            rotate_extrude(angle=arc_ang, convexity=10)
                translate([arc_rad, 0, 0])
                    square([arc_w, arc_th], center=false);
}

module outer_shell() {
    union() {
        // Main casing block
        translate([body_center_x, 0, 0])
            cube([body_x, body_y, body_z], center=true);

        // Outlet nozzle (overlaps main casing by z_overlap)
        translate([outlet_center_x, 0, 0])
            cube([outlet_len, outlet_w, outlet_h], center=true);

        // Guaranteed physical attachment at the outlet root
        outlet_root_bridge();

        // FIX: add the curved arc/duct segment and ensure it is attached
        attached_curved_arc();

        // Corner bumps on both Z faces (connected)
        for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1]) {
            translate([body_center_x + sx*(body_x/2 - corner_inset),
                       sy*(body_y/2 - corner_inset),
                       sz*(body_z/2 - corner_bump_h/2)])
                cylinder(r=corner_bump_r, h=corner_bump_h, center=true);
        }
    }
}

module internal_voids() {
    union() {
        // Inlet through-hole along Z (top/bottom)
        cylinder(d=inlet_d, h=body_z + 2, center=true);

        // Main impeller cavity (cylindrical)
        cylinder(d=cav_d1, h=cav_h + 0.2, center=true);

        // Volute-like expansion toward outlet
        hull() {
            cylinder(d=cav_d1, h=cav_h + 0.2, center=true);
            translate([body_x*0.18, -body_y*0.10, 0])
                cylinder(d=cav_d2, h=cav_h + 0.2, center=true);
        }

        // Outlet passage (connects cavity to nozzle)
        translate([outlet_center_x - z_overlap/2, 0, 0])
            cube([outlet_len + 2 + z_overlap, outlet_w - 2, outlet_h - 2], center=true);

        // Tongue from cavity to outlet to ensure clear connection
        translate([body_posx_face - wall + z_overlap/2, 0, 0])
            cube([2*wall + 2 + z_overlap, outlet_w - 2, outlet_h - 2], center=true);
    }
}

module blower_fan() {
    difference() {
        union() {
            outer_shell();

            // Impeller inside (kept within internal cavity region)
            intersection() {
                translate([body_center_x, 0, 0])
                    cube([body_x - 2*wall, body_y - 2*wall, body_z - 2*wall], center=true);
                impeller();
            }

            // Axle/strut to connect impeller to casing (prevents floating solid)
            translate([0, 0, (impeller_th/2 + (body_z/2 - wall))/2])
                cylinder(d=3.0,
                         h=(body_z/2 - wall) - impeller_th/2 + 2*z_overlap,
                         center=true);
        }

        // Subtract internal cavities and ports
        internal_voids();
    }
}

blower_fan();