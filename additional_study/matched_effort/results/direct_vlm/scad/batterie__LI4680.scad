$fn = 128;

height   = 80.2;
diameter = 46.2;

rotate([90, 0, 0])  // orient cylinder axis along Y so front/back/left/right show height
    cylinder(h = height, d = diameter, center = true);