// Miniature linear guide rail
// Overall size: 100mm (L) x 15.0mm (W) x 12.5mm (H)
// One connected solid (mounting holes + raceways are subtracted)

$fn = 64;

module linear_guide_rail(L=100, W=15.0, H=12.5) {

    // Feature parameters (kept proportional and within envelope)
    chamfer = 0.8;                 // edge chamfer size
    top_flat = 6.0;                // flat land on top between raceways
    race_r = 1.2;                  // raceway groove radius
    race_depth = 1.0;              // how deep the raceway cuts into the top
    hole_d = 3.4;                  // mounting through-hole diameter
    counterbore_d = 6.2;           // counterbore diameter (top)
    counterbore_h = 2.2;           // counterbore depth
    end_margin = 10;               // distance from ends to first/last hole
    hole_count = 5;                // number of holes along length

    // Derived
    eps = 0.02;
    pitch = (L - 2*end_margin) / (hole_count - 1);
    race_y_off = (W - top_flat)/4; // centers of the two raceways from side edges

    difference() {
        // Main body with chamfered long edges and end edges
        chamfered_prism(L, W, H, chamfer);

        // Raceway grooves (two longitudinal concave grooves on top)
        for (side = [-1, 1]) {
            translate([0, W/2 + side*(W/2 - race_y_off), H - race_depth])
                rotate([0, 90, 0])
                    cylinder(r=race_r, h=L + 2*eps, center=false);
        }

        // Mounting holes + counterbores (from top)
        for (i = [0 : hole_count-1]) {
            x = end_margin + i*pitch;

            // Through hole
            translate([x, W/2, -eps])
                cylinder(d=hole_d, h=H + 2*eps, center=false);

            // Counterbore
            translate([x, W/2, H - counterbore_h])
                cylinder(d=counterbore_d, h=counterbore_h + eps, center=false);
        }

        // Small underside relief channel (typical rail underside feature)
        // Keeps overall envelope unchanged; subtracts a shallow groove.
        relief_w = 5.0;
        relief_h = 1.0;
        translate([-eps, (W - relief_w)/2, -eps])
            cube([L + 2*eps, relief_w, relief_h + eps], center=false);
    }
}

// Chamfered rectangular prism using hull of corner posts (no floating parts)
module chamfered_prism(L, W, H, c) {
    // Clamp chamfer to safe range
    c2 = min(c, min(W, H)/2 - 0.01);

    hull() {
        for (x = [0, L])
            for (y = [0, W])
                for (z = [0, H])
                    translate([
                        (x==0) ? c2 : L - c2,
                        (y==0) ? c2 : W - c2,
                        (z==0) ? c2 : H - c2
                    ])
                        cube([2*c2, 2*c2, 2*c2], center=true);
    }
}

linear_guide_rail();