module mounting_plate() {
    difference() {
        union() {
            // Main plate with concave sides
            scale([1, 1, 0.01])
                offset(r=-0.02)
                square([0.1, 0.1], center=true);
            
            // Raised cylindrical boss
            translate([0, 0, 0.01])
                cylinder(h=0.02, d=0.05, $fn=64);
        }
        
        // Corner through-holes
        for (x = [-0.045, 0.045])
            for (y = [-0.045, 0.045])
                translate([x, y, 0])
                    cylinder(h=0.02, d=0.01, $fn=64);
    }
    
    // Central hexagonal protrusion
    translate([0, 0, 0.03])
        rotate([0, 0, 90])
            linear_extrude(height=0.01)
                polygon(points=[[0.01, 0], [0.005, 0.00866], [-0.005, 0.00866], [-0.01, 0], [-0.005, -0.00866], [0.005, -0.00866]]);
}

mounting_plate();