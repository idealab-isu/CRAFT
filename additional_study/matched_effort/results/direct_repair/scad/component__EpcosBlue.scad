$fn=64;

// Thermistor: EPCOS/TDK B57861S104F40 (NTC 100k, 1%)
// Approximate 3D representation: epoxy bead NTC with two radial leads.
// Dimensions are typical/representative (not guaranteed exact datasheet values).

// ---------- Parameters ----------
lead_d = 0.5;          // lead wire diameter (mm)
lead_pitch = 2.54;     // lead spacing (mm)
lead_len = 28;         // straight lead length below bead (mm)

bead_d = 3.2;          // bead diameter (mm)
bead_th = 2.2;         // bead thickness along lead axis (mm)
bead_lead_embed = 0.6; // how far leads appear to enter bead (mm)

kink_drop = 2.0;       // small vertical drop before leads go straight down (mm)
kink_out = 0.8;        // small outward offset near bead (mm)

// ---------- Helpers ----------
module cyl_z(h, d) {
    cylinder(h=h, d=d, center=false);
}

module lead_path(x0, y0, z0) {
    // A simple 3-segment lead: short outward, short down, then long down.
    // Start point is at bead bottom plane (z0), at x0,y0.
    // Segment 1: outward (x direction)
    seg1 = kink_out;
    seg2 = kink_drop;
    seg3 = lead_len;

    // Segment 1 (horizontal)
    translate([x0, y0, z0 - lead_d/2])
        rotate([0,90,0])
            cylinder(h=seg1, d=lead_d, center=false);

    // Segment 2 (down)
    translate([x0 + seg1, y0, z0 - seg2])
        cylinder(h=seg2, d=lead_d, center=false);

    // Segment 3 (down long)
    translate([x0 + seg1, y0, z0 - seg2 - seg3])
        cylinder(h=seg3, d=lead_d, center=false);
}

module thermistor_bead() {
    // Epoxy bead as a rounded capsule-like body
    // Use hull of two spheres to create a pill shape along Z.
    color([0.08,0.08,0.08])
    translate([0,0,0])
    hull() {
        translate([0,0,-bead_th/2 + bead_d/2*0.15])
            sphere(d=bead_d);
        translate([0,0, bead_th/2 - bead_d/2*0.15])
            sphere(d=bead_d);
    }
}

module thermistor() {
    // Coordinate system:
    // Bead centered at origin. Leads exit from bottom face (negative Z).
    bead_bottom_z = -bead_th/2;

    // Bead
    thermistor_bead();

    // Leads (two)
    color([0.75,0.75,0.78]) {
        // short embedded stubs into bead
        for (sx = [-1, 1]) {
            x = sx * lead_pitch/2;
            // embedded portion
            translate([x, 0, bead_bottom_z - bead_lead_embed])
                cylinder(h=bead_lead_embed + 0.01, d=lead_d, center=false);

            // external lead path
            lead_path(x, 0, bead_bottom_z);
        }
    }
}

// ---------- Render ----------
thermistor();