module mounting_plate() {
    difference() {
        // Base plate
        linear_extrude(height=0.01)
        offset(r=0.005)
        polygon(points=[
            [-0.05, -0.05], [0.05, -0.05], [0.05, 0.05], [-0.05, 0.05],
            [-0.03, 0.03], [-0.03, -0.03], [0.03, -0.03], [0.03, 0.03]
        ]);

        // Diamond-shaped holes
        for (x = [-0.03, 0.03]) {
            for (y = [-0.03, 0.03]) {
                translate([x, y, 0])
                rotate(45)
                square([0.01, 0.01], center=true);
            }
        }
    }
}

mounting_plate();