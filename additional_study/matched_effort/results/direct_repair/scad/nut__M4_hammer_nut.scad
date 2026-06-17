$fn = 80;

// T-slot nut parameters (mm)
screw_d = 4.0;          // screw diameter
clearance = 0.4;        // hole clearance
hole_d = screw_d + clearance;

af = 6.0;               // across flats
th = 3.25;              // thickness

// Typical T-slot nut proportions (adjustable)
length = 12.0;          // along slot
top_w = 6.0;            // top width (fits slot opening)
bottom_w = 10.0;        // bottom width (undercut capture)
taper_h = th;           // full-height taper

// Optional small edge chamfer
chamfer = 0.25;

module hex_prism_across_flats(af, h){
    // For a regular hex, across flats = 2*R*cos(30) => R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module tslot_nut(){
    difference(){
        // Body: trapezoidal prism (top narrower than bottom)
        // Use linear_extrude of a 2D trapezoid in X (width) vs Y (length)
        translate([0,0,0])
        linear_extrude(height=th)
            polygon(points=[
                [-top_w/2, -length/2],
                [ top_w/2, -length/2],
                [ bottom_w/2,  length/2],
                [-bottom_w/2,  length/2]
            ]);

        // Through hole for screw
        translate([0,0,-0.5])
            cylinder(h=th+1.0, d=hole_d);

        // Optional shallow top chamfer around hole (countersink-like)
        translate([0,0,th-0.6])
            cylinder(h=0.7, d1=hole_d+1.2, d2=hole_d);

        // Edge chamfers (approx) by subtracting thin wedges
        if (chamfer > 0){
            // Top perimeter chamfer
            translate([0,0,th-chamfer])
                linear_extrude(height=chamfer+0.01, scale=(top_w-2*chamfer)/top_w)
                    polygon(points=[
                        [-top_w/2, -length/2],
                        [ top_w/2, -length/2],
                        [ bottom_w/2,  length/2],
                        [-bottom_w/2,  length/2]
                    ]);
        }
    }
}

tslot_nut();