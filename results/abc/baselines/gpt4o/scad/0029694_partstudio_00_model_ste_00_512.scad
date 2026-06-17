module bracket() {
    difference() {
        union() {
            // Central ring
            difference() {
                cylinder(h=1, r=5, $fn=64);
                cylinder(h=2, r=2, $fn=64);
            }
            
            // Horizontal clevis arm
            translate([5, 0, 0])
            union() {
                cube([10, 2, 1], center=true);
                translate([5, 0, 0])
                difference() {
                    cube([4, 2, 1], center=true);
                    translate([2, 0, 0])
                    cube([2, 1, 1.1], center=true);
                }
            }
            
            // Vertical clevis arm
            translate([0, 5, 0])
            rotate([0, 0, 90])
            union() {
                cube([10, 2, 1], center=true);
                translate([5, 0, 0])
                difference() {
                    cube([4, 2, 1], center=true);
                    translate([2, 0, 0])
                    cube([2, 1, 1.1], center=true);
                }
            }
        }
    }
}

translate([0, 0, -0.5])
scale([0.01, 0.01, 0.01])
bracket();