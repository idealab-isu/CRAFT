$fn=64;

eps = 0.01;

// Fallback minimal printable size since given bounding box is effectively zero
L = 40;
W = 30;
H = 20;

// Wedge parameters
h_low = 8;
h_high = 20;

// Flange/step and foot
flange_len = 10;
flange_extra_h = 6;
foot_len = 8;
foot_h = 4;
foot_w = 18;

// Holes on sloped/side region
hole_d = 4;
hole2_d = 6;
hole_depth = W + 2;

module wedge_body(len=L, wid=W, h1=h_low, h2=h_high) {
    polyhedron(
        points=[
            [-len/2, -wid/2, 0],
            [ len/2, -wid/2, 0],
            [ len/2,  wid/2, 0],
            [-len/2,  wid/2, 0],
            [-len/2, -wid/2, h1],
            [ len/2, -wid/2, h2],
            [ len/2,  wid/2, h2],
            [-len/2,  wid/2, h1]
        ],
        faces=[
            [0,1,2,3],
            [4,7,6,5],
            [0,4,5,1],
            [1,5,6,2],
            [2,6,7,3],
            [3,7,4,0]
        ]
    );
}

module flange_and_foot() {
    union() {
        // Vertical flange/step at one end (x = -L/2 side)
        translate([-L/2 + flange_len/2, 0, (h_low + flange_extra_h)/2])
            cube([flange_len, W, h_low + flange_extra_h], center=true);

        // Small lower protruding foot near same end
        translate([-L/2 + foot_len/2, 0, foot_h/2])
            cube([foot_len, foot_w, foot_h], center=true);
    }
}

module side_holes() {
    // Two holes entering from +Y side into the body, positioned along length and height
    for (p = [
        [-5, 0, 10, hole_d],
        [ 8, 0, 14, hole2_d]
    ]) {
        translate([p[0], W/2 + 0.5, p[2]])
            rotate([90,0,0])
                cylinder(d=p[3], h=hole_depth, center=true);
    }
}

module bracket() {
    difference() {
        union() {
            wedge_body();
            flange_and_foot();
        }
        side_holes();

        // Small recessed pocket on sloped/side region
        translate([6, W/2 - 4, 12])
            rotate([90,0,0])
                cylinder(d=10, h=6, center=true);

        // Clearance notch near broad flat face end (x = +L/2)
        translate([L/2 - 6, 0, 6])
            cube([12, 14, 10], center=true);
    }
}

// Center at origin
bracket();