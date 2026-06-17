$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 5.8 mm
// Length: 4.6 mm
// For M2.5 screw: internal thread approximated as a straight bore near tap size

od = 5.8;
len = 4.6;

// Typical M2.5 internal thread minor diameter is ~2.05–2.15 mm.
// Use a slightly generous bore for printed visualization.
id_bore = 2.2;

// Small lead-in chamfers
chamfer = 0.35;

// Optional shallow knurl-like rings to resemble heat-set insert texture
ring_count = 7;
ring_depth = 0.25;
ring_width = 0.35;

module insert_body() {
    difference() {
        // Outer body
        cylinder(d=od, h=len);

        // Internal bore
        translate([0,0,-0.01])
            cylinder(d=id_bore, h=len+0.02);

        // Chamfer top
        translate([0,0,len-chamfer])
            cylinder(d1=id_bore+0.8, d2=id_bore, h=chamfer+0.01);

        // Chamfer bottom
        translate([0,0,-0.01])
            cylinder(d1=id_bore, d2=id_bore+0.8, h=chamfer+0.02);

        // Ring grooves (shallow)
        for (i = [0:ring_count-1]) {
            z0 = (len/(ring_count+1))*(i+1) - ring_width/2;
            translate([0,0,z0])
                difference() {
                    cylinder(d=od+0.02, h=ring_width);
                    translate([0,0,-0.01])
                        cylinder(d=od-2*ring_depth, h=ring_width+0.02);
                }
        }
    }
}

insert_body();