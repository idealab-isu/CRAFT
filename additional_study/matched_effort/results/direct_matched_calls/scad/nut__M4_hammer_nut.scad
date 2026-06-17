$fn = 80;

// T-slot nut parameters (mm)
screw_d = 4.0;          // screw diameter
clearance = 0.4;        // clearance for screw hole
hole_d = screw_d + clearance;

across_flats = 6.0;     // hex across flats
thickness = 3.25;       // nut thickness

// Small edge chamfer to ease insertion (approx)
chamfer = 0.25;

// Derived
hex_R = across_flats / sqrt(3); // circumradius for hex with given across-flats

module hex_prism(h, R){
    linear_extrude(height=h)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

module tslot_nut(){
    difference(){
        // Body with slight chamfer on both faces
        union(){
            // middle section
            translate([0,0,chamfer])
                hex_prism(thickness - 2*chamfer, hex_R);

            // bottom chamfer
            hull(){
                translate([0,0,0])
                    hex_prism(0.01, hex_R);
                translate([0,0,chamfer])
                    hex_prism(0.01, max(hex_R - chamfer, 0.01));
            }

            // top chamfer
            hull(){
                translate([0,0,thickness - chamfer])
                    hex_prism(0.01, max(hex_R - chamfer, 0.01));
                translate([0,0,thickness])
                    hex_prism(0.01, hex_R);
            }
        }

        // Through hole for screw
        translate([0,0,-0.5])
            cylinder(h=thickness+1.0, d=hole_d);
    }
}

tslot_nut();