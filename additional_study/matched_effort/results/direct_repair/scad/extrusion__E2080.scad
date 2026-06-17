$fn = 64;

// 20x80 aluminium extrusion profile (simplified as a solid rectangular prism)
// Cross-section: 20.0mm x 80.0mm
// Length: 100mm

w = 20.0;
h = 80.0;
len = 100.0;

color([0.75, 0.75, 0.78])
translate([-w/2, -h/2, 0])
cube([w, h, len], center=false);