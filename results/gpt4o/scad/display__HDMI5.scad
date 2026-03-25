module display() {
    // Main display body
    translate([0, 0, 1.9])
    cube([121, 76, 2.85], center=true);

    // PCB aperture
    translate([-54, -30.225, 0])
    cube([108, 64.8, 0.5], center=false);

    // Touch screen
    translate([-58.7, -34, 0])
    cube([117.4, 70.25, 1], center=false);

    // Clearance for the touch screen ribbon
    translate([-2.5, -39, 0])
    cube([13, 6, 2.85], center=false);
}

display();