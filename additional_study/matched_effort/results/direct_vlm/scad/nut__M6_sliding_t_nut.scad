$fn = 96;

// Required dimensions (mm)
screw_d = 6.0;          // nominal screw size (reference)
clear_d = 6.6;          // clearance hole for M6
af      = 8.0;          // across flats (hex)
th      = 6.6;          // total thickness

// T-slot nut body (parametric defaults; adjust to your extrusion slot)
body_len = 18.0;
body_w   = 12.0;
corner_r = 1.0;

// T-slot step/undercut (creates the "T" profile)
step_h = 2.2;           // height of the narrower top section
step_w = 8.0;           // width of the narrower top section (<= body_w)
step_len = body_len;    // keep same length for a simple T-nut

// Anti-rotation nibs (small side ribs on the wider base)
nib_w   = 10.0;         // along length
nib_t   = 0.8;          // protrusion thickness (outward)
nib_h   = th - step_h;  // only on the lower (wider) portion

// Chamfers around the through-hole
top_chamfer    = 0.6;
bottom_chamfer = 0.4;

// Hex pocket depth (nut capture) from top face
hex_depth = 4.8;

// Small overlap to ensure watertight unions/differences
eps = 0.02;

// Helper: rounded rectangle prism (Z from 0..h)
module rounded_rect_prism(l, w, h, r){
    r2 = min(r, min(l,w)/2);
    linear_extrude(height=h)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

// Helper: hex prism by across-flats (Z from 0..h)
module hex_prism_af(af, h){
    // across-flats = sqrt(3) * R (circumradius)
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference(){
    union(){
        // Lower (wider) base: Z = 0 .. (th - step_h)
        rounded_rect_prism(body_len, body_w, th - step_h, corner_r);

        // Upper (narrower) step: Z = (th - step_h) .. th
        translate([0,0,th - step_h - eps])
            rounded_rect_prism(step_len, step_w, step_h + eps, corner_r);

        // Anti-rotation nibs on the lower base only (connected, no floating)
        translate([0,  body_w/2 + nib_t/2 - eps, (th - step_h)/2])
            cube([nib_w, nib_t + 2*eps, nib_h], center=true);
        translate([0, -body_w/2 - nib_t/2 + eps, (th - step_h)/2])
            cube([nib_w, nib_t + 2*eps, nib_h], center=true);
    }

    // Through clearance hole (goes fully through)
    translate([0,0,-eps])
        cylinder(d=clear_d, h=th + 2*eps);

    // Top chamfer around hole
    translate([0,0,th - top_chamfer])
        cylinder(d1=clear_d + 2*top_chamfer, d2=clear_d, h=top_chamfer + eps);

    // Bottom chamfer around hole
    translate([0,0,-eps])
        cylinder(d1=clear_d, d2=clear_d + 2*bottom_chamfer, h=bottom_chamfer + 2*eps);

    // Hex pocket on top for 8mm across flats (visible in top view)
    translate([0,0,th - hex_depth])
        hex_prism_af(af, hex_depth + eps);
}