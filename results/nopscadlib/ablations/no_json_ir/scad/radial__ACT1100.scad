// Parameters
outer_radius = 20.4;
inner_radius = 10.8;
height = 5.3;
wall_thickness = 1;

// Derived parameters
bore_radius = inner_radius - wall_thickness;
chamfer_size = 0.5;
fillet_radius = 0.5;

// Main module
module radial_part() {
    difference() {
        // Outer cylinder
        cylinder(h = height, r = outer_radius, $fn = 100);
        
        // Inner bore
        translate([0, 0, -1]) // Slightly extend to ensure clean subtraction
            cylinder(h = height + 2, r = bore_radius, $fn = 100);
    }
    
    // Edge chamfers
    chamfer_edges();
    
    // Fillets
    fillet_edges();
}

// Chamfer edges
module chamfer_edges() {
    translate([0, 0, height - chamfer_size])
        rotate_extrude($fn = 100)
            translate([outer_radius - chamfer_size, 0, 0])
                square([chamfer_size, chamfer_size], center = true);
    
    rotate_extrude($fn = 100)
        translate([outer_radius - chamfer_size, 0, 0])
            square([chamfer_size, chamfer_size], center = true);
}

// Fillet edges
module fillet_edges() {
    translate([0, 0, fillet_radius])
        rotate_extrude($fn = 100)
            translate([outer_radius - fillet_radius, 0, 0])
                circle(r = fillet_radius);
    
    translate([0, 0, height - fillet_radius])
        rotate_extrude($fn = 100)
            translate([outer_radius - fillet_radius, 0, 0])
                circle(r = fillet_radius);
}

// Render the part
radial_part();