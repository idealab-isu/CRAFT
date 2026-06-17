module rounded_rectangle_plate() {
    difference() {
        union() {
            // Main plate
            translate([-50, -25, 0])
                offset(r=5)
                    square([100, 50], center=false);

            // Chamfered corner blocks
            translate([-50, -25, 0])
                offset(delta=-5)
                    square([10, 10], center=false);
            translate([40, -25, 0])
                offset(delta=-5)
                    square([10, 10], center=false);
        }

        // Elongated hexagonal/slot-like openings
        for (x = [-30, 0, 30]) {
            translate([x, 0, 0])
                rotate([0, 0, 90])
                    offset(r=2)
                        square([30, 10], center=true);
        }

        // Diamond-shaped openings
        for (x = [-20, 20]) {
            translate([x, 15, 0])
                rotate([0, 0, 45])
                    square([10, 10], center=true);
        }

        // Triangular openings
        for (x = [-40, 40]) {
            translate([x, -15, 0])
                polygon(points=[[0,0], [5,10], [-5,10]]);
        }
    }
}

rounded_rectangle_plate();