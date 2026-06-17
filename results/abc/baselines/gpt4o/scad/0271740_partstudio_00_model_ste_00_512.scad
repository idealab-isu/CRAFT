module mounting_bracket() {
    $fn = 64;
    
    // Central barrel-shaped body
    module barrel_body() {
        difference() {
            scale([1, 0.5, 1])
                cylinder(h=10, r=5, center=true);
            translate([-5, -2.5, -5])
                cube([10, 5, 10], center=true);
        }
    }
    
    // Rounded tab with two holes
    module rounded_tab() {
        difference() {
            translate([0, 0, -5])
                cylinder(h=10, r=5, center=true);
            translate([-2, 0, -5])
                cylinder(h=10, r=1, center=true);
            translate([2, 0, -5])
                cylinder(h=10, r=1, center=true);
        }
    }
    
    // Forked clevis with U-shaped opening
    module forked_clevis() {
        difference() {
            translate([0, 0, 5])
                cube([10, 5, 10], center=true);
            translate([0, 0, 5])
                cylinder(h=10, r=5, center=true);
            translate([0, 0, 5])
                cube([10, 5, 10], center=true);
            translate([-5, 0, 5])
                cube([10, 5, 10], center=true);
            translate([0, 0, 5])
                cube([10, 5, 10], center=true);
        }
    }
    
    // Diamond-shaped hole in the main body
    module diamond_hole() {
        rotate([0, 0, 45])
            translate([0, 0, 0])
                scale([1, 0.5, 1])
                    cylinder(h=10, r=1, center=true);
    }
    
    // Assemble the mounting bracket
    union() {
        barrel_body();
        translate([0, 0, -10])
            rounded_tab();
        translate([0, 0, 10])
            forked_clevis();
        diamond_hole();
    }
}

mounting_bracket();