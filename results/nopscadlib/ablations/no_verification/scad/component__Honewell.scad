// Honeywell 135-104LAC-J01 style radial leaded thermistor (approximate geometry)
// Goal: one connected solid, bead/epoxy body with two radial leads and a small neck.
// No arbitrary translate values: all placements derived from dimensions.

$fn = 64;

// Parameters (mm)
body_d = 2.2;          //[1.1:4.4:0.1]  epoxy bead diameter
body_l = 3.5;          //[1.75:7:0.1]   epoxy bead length (along X)
neck_d = 1.2;          //[0.6:2.4:0.1]  neck diameter (lead exit)
neck_l = 1.0;          //[0.5:2:0.1]    neck length (along X)
lead_d = 0.5;          //[0.25:1:0.05]  lead diameter
lead_l = 25;           //[12.5:50:0.5]  lead length (along +X from body)
lead_pitch = 2.54;     //[1.27:5.08:0.01] lead spacing (Y)
overlap = 0.6;         //[0.3:2:0.1]    overlap to ensure watertight unions
tinning_l = 2.5;       //[1:6:0.1]      optional thicker/tinned end length
marking_depth = 0.12;  //[0.05:0.4:0.01] shallow flat/mark on body

// Derived
body_r = body_d/2;
neck_r = neck_d/2;
lead_r = lead_d/2;

// Body is centered at origin, oriented along X
module epoxy_body() {
    // Slightly rounded capsule-like body using hull of two spheres
    hull() {
        translate([-body_l/2 + body_r, 0, 0]) sphere(r=body_r);
        translate([ body_l/2 - body_r, 0, 0]) sphere(r=body_r);
    }
}

// Two necks exiting the body toward +X at +/- lead_pitch/2
module necks() {
    for (sy = [-1, 1]) {
        translate([ body_l/2 + neck_l/2 - overlap, sy*lead_pitch/2, 0])
            rotate([0, 90, 0])
                cylinder(r=neck_r, h=neck_l, center=true);
    }
}

// Leads start inside necks and extend to +X
module leads() {
    // Lead center position along X:
    // neck end at x = body_l/2 + neck_l - overlap
    // lead centered at that + lead_l/2 - overlap (so it overlaps into neck)
    lead_cx = body_l/2 + neck_l - overlap + lead_l/2 - overlap;

    for (sy = [-1, 1]) {
        translate([lead_cx, sy*lead_pitch/2, 0])
            rotate([0, 90, 0])
                cylinder(r=lead_r, h=lead_l, center=true);
    }
}

// Optional slightly thicker "tinned" tips at the far end (kept connected)
module lead_tips() {
    tip_r = lead_r * 1.05; // subtle, avoids looking like separate rails
    tip_cx = (body_l/2 + neck_l - overlap) + (lead_l - tinning_l/2);

    for (sy = [-1, 1]) {
        translate([tip_cx, sy*lead_pitch/2, 0])
            rotate([0, 90, 0])
                cylinder(r=tip_r, h=tinning_l, center=true);
    }
}

// Shallow flat on the body to suggest a molded/epoxy feature (no text)
module body_flat_mark() {
    // Cut a small flat on the top (Z+) of the epoxy body
    // Place cutter so it intersects the body surface by marking_depth.
    translate([0, 0, body_r - marking_depth])
        cube([body_l*0.55, body_d*0.75, marking_depth*2], center=true);
}

module thermistor() {
    difference() {
        union() {
            epoxy_body();
            necks();
            leads();
            lead_tips();
        }
        body_flat_mark();
    }
}

thermistor();