// Bi-metal saw blade (single connected solid, no text)

module saw_blade(
    L = 200,          // overall length
    W = 20,           // overall width
    T = 1.2,          // thickness (Z)
    tooth_pitch = 4,  // distance between teeth
    tooth_h = 2.2,    // tooth height (protrusion in -Y)
    tooth_base = 3.2, // tooth base length along blade (X)
    tooth_set = 0.35, // alternating side set (visual, in Z)
    bimetal_w = 3.0,  // width of hardened tooth strip region (Y)
    hole_r = 2.0,
    hole_margin = 6.0,
    chamfer = 2.0
) {
    eps = 0.05;
    overlap = 0.2; // small overlap to guarantee watertight unions

    // Derived
    n_teeth = max(1, floor((L - 2*hole_margin) / tooth_pitch));
    teeth_x0 = -L/2 + hole_margin;
    y_edge = -W/2; // toothed edge at negative Y

    // Tooth prism thickness (slightly proud but still fused)
    tooth_T = T + 0.25;

    difference() {
        union() {
            // Main blade body
            cube([L, W, T], center=true);

            // Bi-metal strip (fused, slightly proud in Z)
            translate([0, y_edge + bimetal_w/2 + overlap/2, 0])
                cube([L, bimetal_w + overlap, T + 0.25], center=true);

            // Teeth: trapezoid prisms along the toothed edge, fused into blade
            for (i = [0 : n_teeth-1]) {
                x = teeth_x0 + (i + 0.5) * tooth_pitch;
                set_dir = (i % 2 == 0) ? 1 : -1;

                // Main tooth body (extruded in Z), overlaps into blade by 'overlap'
                translate([x, y_edge + overlap/2, 0])
                    linear_extrude(height = tooth_T, center=true)
                        polygon(points=[
                            [-tooth_base/2,  overlap],                 // inside blade
                            [ tooth_base/2,  overlap],                 // inside blade
                            [ tooth_base/2 - 0.6, -tooth_h],           // tip region
                            [-tooth_base/2 + 0.6, -tooth_h]
                        ]);

                // Alternating set: small Z-offset rib that remains connected (overlaps tooth body)
                translate([x, y_edge - tooth_h*0.55, set_dir*(tooth_set/2)])
                    cube([tooth_base*0.55, tooth_set + overlap, tooth_T], center=true);
            }
        }

        // Mounting hole near one end (through thickness)
        hole_x = -L/2 + hole_margin;
        translate([hole_x, 0, 0])
            cylinder(h = T + 2, r = hole_r, center=true, $fn=64);

        // Corner chamfers on the non-toothed edge (+Y), subtract wedges that fully intersect the body
        // Left top corner
        translate([-L/2 - eps, W/2 - chamfer, -T/2 - 1])
            linear_extrude(height = T + 2, center=false)
                polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
        // Right top corner
        translate([ L/2 - chamfer, W/2 - chamfer, -T/2 - 1])
            linear_extrude(height = T + 2, center=false)
                polygon(points=[[0,0],[chamfer,0],[chamfer,chamfer]]);

        // Light gullet relief between teeth (shallow notches), kept within tooth region
        for (i = [0 : n_teeth-2]) {
            xg = teeth_x0 + (i + 1) * tooth_pitch;
            translate([xg, y_edge - tooth_h*0.35, 0])
                cube([tooth_pitch*0.35, tooth_h*0.55, tooth_T + 2], center=true);
        }
    }
}

saw_blade();