// Miniature linear guide rail
// Overall size: 12.0mm (W) x 8.0mm (H) x 100mm (L)

$fn = 64;

module linear_guide_rail(W=12, H=8, L=100) {

    // Profile parameters (kept within W/H)
    base_h   = 2.2;
    head_h   = 2.0;
    web_h    = H - base_h - head_h;

    base_w   = W;
    head_w   = W;
    web_w    = 6.0;

    // Raceway grooves (cosmetic)
    groove_r = 0.9;
    groove_z = base_h + web_h + head_h*0.55; // near top
    groove_x = W/2 - 1.6;                    // near edges

    // Mounting holes (through) + countersink (top)
    hole_d   = 3.0;
    cs_d     = 5.6;
    cs_h     = 1.4;

    // Hole pattern along length
    n_holes  = 5;
    end_marg = 10;
    pitch    = (L - 2*end_marg) / (n_holes - 1);

    // Small end chamfer (subtractive)
    chamfer  = 0.8;

    difference() {
        // --- Solid rail body (one connected solid) ---
        union() {
            // Base
            translate([-base_w/2, 0, 0])
                cube([base_w, L, base_h], center=false);

            // Web
            translate([-web_w/2, 0, base_h])
                cube([web_w, L, web_h], center=false);

            // Head
            translate([-head_w/2, 0, base_h + web_h])
                cube([head_w, L, head_h], center=false);
        }

        // --- Mounting holes + countersinks (subtractive) ---
        for (i = [0 : n_holes-1]) {
            y = end_marg + i*pitch;

            // Through hole (Z axis)
            translate([0, y, -0.2])
                cylinder(d=hole_d, h=H+0.4, center=false);

            // Countersink from top
            translate([0, y, H - cs_h])
                cylinder(d1=cs_d, d2=hole_d, h=cs_h+0.2, center=false);
        }

        // --- Raceway grooves (subtractive), run full length ---
        for (sx = [-1, 1]) {
            translate([sx*groove_x, L/2, groove_z])
                rotate([90, 0, 0])
                    cylinder(r=groove_r, h=L+0.6, center=true);
        }

        // --- End chamfers (subtractive wedges) ---
        // Front end (y=0)
        translate([-W/2 - 0.2, -0.2, H - chamfer])
            rotate([0, 90, 0])
                linear_extrude(height=W+0.4)
                    polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);

        // Back end (y=L)
        translate([-W/2 - 0.2, L+0.2, H - chamfer])
            rotate([180, 90, 0])
                linear_extrude(height=W+0.4)
                    polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
    }
}

linear_guide_rail();