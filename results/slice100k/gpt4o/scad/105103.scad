module serrated_blade() {
    difference() {
        union() {
            // Main blade body
            translate([-12.2, -49.65, 0])
                cube([24.4, 99.3, 3]);

            // Serrated edge
            for (i = [0:11]) {
                translate([-12.2 + i * 2, 49.65, 0])
                    rotate([0, 0, 180])
                    polygon(points=[[0, 0], [2, 0], [1, 2]]);
            }

            // Chamfered tip
            translate([-12.2, 49.65, 0])
                polygon(points=[[0, 0], [24.4, 0], [12.2, -12.2]]);
        }

        // Mounting plate
        translate([-12.2, -49.65, 0])
            polygon(points=[[0, 0], [24.4, 0], [12.2, -12.2], [-12.2, -12.2]]);

        // Circular through-holes
        translate([-6, -45, 1.5])
            cylinder(h=3, r=2, $fn=64);
        translate([6, -45, 1.5])
            cylinder(h=3, r=2, $fn=64);

        // Central gear/star-shaped cutout
        translate([0, -49.65, 1.5])
            rotate([0, 0, 90])
            star_shape(5, 4, 8, 3);
    }
}

module star_shape(points, inner_r, outer_r, h) {
    rotate_extrude($fn=64)
        translate([outer_r, 0, 0])
        polygon(points=star_points(points, inner_r, outer_r));
}

function star_points(points, inner_r, outer_r) = 
    [for (i = [0:points-1]) 
        let (angle = i * 360 / points)
        [outer_r * cos(angle), outer_r * sin(angle)],
        [inner_r * cos(angle + 360 / (2 * points)), inner_r * sin(angle + 360 / (2 * points))]];

serrated_blade();