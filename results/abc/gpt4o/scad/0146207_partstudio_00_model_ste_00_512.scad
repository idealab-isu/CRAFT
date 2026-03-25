module mounting_plate() {
    difference() {
        // Base plate with rounded corners
        offset(r=0.02) {
            square([0.16, 0.26], center=true);
        }
        
        // Corner fastener holes
        for (x = [-0.07, 0.07])
        for (y = [-0.12, 0.12])
            translate([x, y, 0])
                cylinder(h=0.01, r=0.005, center=true, $fn=64);
    }
}

module diamond_tab() {
    polygon(points=[[0, 0.015], [0.015, 0], [0, -0.015], [-0.015, 0]]);
    translate([0, 0, 0])
        cylinder(h=0.01, r=0.005, center=true, $fn=64);
}

module bezel() {
    difference() {
        // Raised octagonal bezel
        translate([0, 0, 0.005])
            cylinder(h=0.01, r=0.05, $fn=8, center=true);
        
        // Recessed rectangular pocket
        translate([-0.03, -0.04, 0.005])
            cube([0.06, 0.08, 0.01], center=false);
    }
}

module faceplate() {
    union() {
        mounting_plate();
        
        // Diamond-shaped tabs
        translate([0, 0.13, 0])
            diamond_tab();
        translate([0, -0.13, 0])
            diamond_tab();
        
        // Central bezel
        bezel();
    }
}

scale([1, 1, 0.001])
    faceplate();