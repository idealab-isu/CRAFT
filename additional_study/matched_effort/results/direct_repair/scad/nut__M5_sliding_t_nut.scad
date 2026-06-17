$fn = 96;

// T-slot nut parameters (mm)
screw_d = 5.0;          // screw diameter
clearance = 0.4;        // clearance for through-hole
hole_d = screw_d + clearance;

across_flats = 6.0;     // hex across flats
thickness = 3.7;        // nut thickness

// Small edge chamfer (visual + easier insertion)
chamfer = 0.25;

// Derived
hex_R = across_flats / sqrt(3); // circumradius for hex with given across-flats

module hex_prism(h, R){
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module tslot_nut(){
    difference(){
        // Body with slight chamfer on both faces
        union(){
            // main
            translate([0,0,chamfer])
                hex_prism(thickness - 2*chamfer, hex_R);

            // bottom chamfer
            linear_extrude(height=chamfer, scale=(hex_R - chamfer)/hex_R)
                polygon([ for(i=[0:5]) [ hex_R*cos(60*i), hex_R*sin(60*i) ] ]);

            // top chamfer
            translate([0,0,thickness - chamfer])
                linear_extrude(height=chamfer, scale=(hex_R - chamfer)/hex_R)
                    polygon([ for(i=[0:5]) [ hex_R*cos(60*i), hex_R*sin(60*i) ] ]);
        }

        // Through hole
        translate([0,0,-0.5])
            cylinder(h=thickness+1.0, d=hole_d);
    }
}

tslot_nut();