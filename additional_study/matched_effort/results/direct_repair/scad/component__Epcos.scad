$fn = 64;

// Thermistor: EPCOS/TDK B57560G104F (100k NTC), generic radial epoxy bead approximation
// Note: Dimensions are typical/approximate for visualization; not an exact datasheet model.

module thermistor_b57560g104f(
    bead_d = 2.2,          // epoxy bead diameter
    bead_l = 3.2,          // epoxy bead length along lead axis
    lead_d = 0.45,         // lead wire diameter
    lead_pitch = 2.54,     // center-to-center spacing of leads
    lead_len = 28,         // straight lead length below bead
    lead_embed = 1.2,      // how far leads embed into bead
    kink_drop = 2.0,       // small vertical drop before leads go straight down
    kink_len = 2.0         // horizontal run from bead to lead centerline
) {
    // Coordinate system:
    // Bead centered at origin, axis along X.
    // Leads exit from bead underside (negative Z), then bend to pitch and go down.

    // Materials/colors (preview only)
    bead_col = [0.08, 0.08, 0.10];   // dark epoxy
    lead_col = [0.75, 0.75, 0.78];   // tinned copper

    // Bead body (capsule-like)
    module bead() {
        color(bead_col)
        hull() {
            translate([-bead_l/2 + bead_d/2, 0, 0]) sphere(d=bead_d);
            translate([ bead_l/2 - bead_d/2, 0, 0]) sphere(d=bead_d);
        }
    }

    // One lead path (polyline swept by hull of spheres)
    module lead_path(side=1) {
        // side: +1 for +Y lead, -1 for -Y lead
        y_target = side * (lead_pitch/2);

        // Exit point from bead underside near center
        p0 = [0, 0, -bead_d/2 + 0.05];
        // Embed slightly into bead
        p1 = [0, 0, -bead_d/2 - lead_embed];
        // Drop a bit
        p2 = [0, 0, -bead_d/2 - lead_embed - kink_drop];
        // Move sideways to pitch
        p3 = [0, y_target, -bead_d/2 - lead_embed - kink_drop];
        // Small horizontal run (optional)
        p4 = [0, y_target, -bead_d/2 - lead_embed - kink_drop - 0.01];
        // Straight down
        p5 = [0, y_target, -bead_d/2 - lead_embed - kink_drop - lead_len];

        // Sweep by hulling spheres along segments
        color(lead_col)
        union() {
            for (seg = [
                [p0,p1],
                [p1,p2],
                [p2,p3],
                [p3,p5]
            ]) {
                hull() {
                    translate(seg[0]) sphere(d=lead_d);
                    translate(seg[1]) sphere(d=lead_d);
                }
            }
        }
    }

    // Lead holes in bead (for a cleaner look)
    module lead_holes() {
        for (side = [-1, 1]) {
            y_target = side * (lead_pitch/2);
            // Drill from underside into bead
            translate([0, 0, -bead_d/2 - 0.2])
                rotate([0,90,0])
                cylinder(d=lead_d*1.15, h=bead_l + 2, center=true);
            // Slightly angled/offset channel toward lead pitch
            hull() {
                translate([0, 0, -bead_d/2 - 0.6])
                    cylinder(d=lead_d*1.2, h=0.8, center=true);
                translate([0, y_target, -bead_d/2 - 0.6 - kink_drop])
                    cylinder(d=lead_d*1.2, h=0.8, center=true);
            }
        }
    }

    // Assemble
    union() {
        difference() {
            bead();
            lead_holes();
        }
        lead_path(-1);
        lead_path( 1);
    }
}

// Render
thermistor_b57560g104f();