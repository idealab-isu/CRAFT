$fn=64;

// Parameters
bearing_diameter = 22; // 608 bearing outer diameter
bearing_width = 7; // 608 bearing width
idler_diameter = 24; // Idler diameter for GT2 belt
idler_width = 8; // Idler width
arm_length = 60; // Length of the pivot arm
arm_width = 10; // Width of the pivot arm
arm_thickness = 5; // Thickness of the pivot arm
spring_diameter = 10; // Diameter of the spring
spring_length = 30; // Length of the spring
pivot_hole_diameter = 5; // Diameter of the pivot hole

// Idler with bearing
module idler_with_bearing() {
    difference() {
        cylinder(d=bearing_diameter, h=bearing_width, center=true);
        translate([0, 0, -bearing_width/2])
            cylinder(d=bearing_diameter - 2, h=bearing_width + 2, center=true);
    }
}

// Pivot arm
module pivot_arm() {
    difference() {
        cube([arm_length, arm_width, arm_thickness], center=true);
        translate([-arm_length/2 + pivot_hole_diameter/2, 0, 0])
            cylinder(d=pivot_hole_diameter, h=arm_thickness + 2, center=true);
    }
}

// Spring
module spring() {
    translate([0, 0, -spring_length/2])
        cylinder(d=spring_diameter, h=spring_length, center=true);
}

// Assembly
module belt_tensioner() {
    union() {
        // Idler
        translate([arm_length/2 - idler_diameter/2, 0, 0])
            idler_with_bearing();
        
        // Pivot arm
        pivot_arm();
        
        // Spring
        translate([-arm_length/2 + spring_diameter/2, 0, 0])
            spring();
    }
}

// Render the belt tensioner
belt_tensioner();