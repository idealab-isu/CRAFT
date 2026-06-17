$fn = 64;

// Miniature linear guide rail (approximate profile)
// Overall: 20.0mm wide, 17.5mm tall, 100mm long

rail_w = 20.0;
rail_h = 17.5;
rail_l = 100.0;

// Profile parameters (kept within overall envelope)
base_h = 6.0;
mid_h  = 6.0;
top_h  = rail_h - base_h - mid_h; // 5.5

base_w = rail_w;      // 20
mid_w  = 14.0;
top_w  = 10.0;

edge_r = 0.8;         // small edge rounding
hole_d = 4.2;         // mounting hole diameter
csk_d  = 7.8;         // counterbore diameter
csk_h  = 2.2;         // counterbore depth
hole_pitch = 25.0;
hole_margin = 12.5;   // from each end

module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounding; ensure r not too large
    rr = min(r, min(size[0], min(size[1], size[2]))/2 - 0.001);
    minkowski() {
        cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=false);
        sphere(r=rr);
    }
}

module rail_body() {
    // Build stepped profile along length (X), width (Y), height (Z)
    // Use rounded outer edges by rounding the full envelope then carving steps.
    difference() {
        // Outer envelope with slight rounding
        translate([0, 0, 0])
            rounded_box([rail_l, rail_w, rail_h], r=edge_r);

        // Carve side steps to form narrower mid and top sections
        // Mid section: centered, from base_h to base_h+mid_h
        // Remove material on both sides outside mid_w
        translate([-1, (rail_w-mid_w)/2 + mid_w, base_h])
            cube([rail_l+2, (rail_w-mid_w)/2 + 2, mid_h + top_h + 2], center=false);
        translate([-1, -2, base_h])
            cube([rail_l+2, (rail_w-mid_w)/2 + 2, mid_h + top_h + 2], center=false);

        // Top section: centered, from base_h+mid_h to rail_h
        // Remove material on both sides outside top_w (only in top region)
        translate([-1, (rail_w-top_w)/2 + top_w, base_h+mid_h])
            cube([rail_l+2, (rail_w-top_w)/2 + 2, top_h + 2], center=false);
        translate([-1, -2, base_h+mid_h])
            cube([rail_l+2, (rail_w-top_w)/2 + 2, top_h + 2], center=false);

        // Add shallow raceway grooves on both sides of the top section
        groove_r = 1.6;
        groove_z = base_h + mid_h + top_h*0.55;
        groove_y_off = (top_w/2) + 0.9;
        for (side = [-1, 1]) {
            translate([rail_l/2, rail_w/2 + side*groove_y_off, groove_z])
                rotate([0,90,0])
                    cylinder(h=rail_l+2, r=groove_r, center=true);
        }

        // Mounting holes with counterbore from bottom
        for (x = [hole_margin : hole_pitch : rail_l - hole_margin + 0.001]) {
            // Through hole
            translate([x, rail_w/2, -1])
                cylinder(h=rail_h+2, d=hole_d, center=false);

            // Counterbore (bottom)
            translate([x, rail_w/2, -0.01])
                cylinder(h=csk_h, d=csk_d, center=false);
        }
    }
}

rail_body();