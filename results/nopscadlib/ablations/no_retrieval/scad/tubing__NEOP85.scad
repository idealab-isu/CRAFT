// Neoprene tubing (hollow) — single connected solid
// Oriented along X so front/back/left/right orthographic views show the tube length.

// Parameters
tube_length    = 300; //[150:600:1]
outer_diameter = 10;  //[5:20:0.5]
inner_diameter = 6;   //[3:12:0.5]
end_chamfer    = 0.5; //[0:2:0.1]
overlap        = 1;   //[0.5:2:0.1]

$fn = 128;

// Derived
outer_r = outer_diameter/2;
inner_r = min(inner_diameter/2, outer_r - 0.01);          // ensure valid wall thickness
ch      = min(end_chamfer, tube_length/2 - 0.01);
eps     = 0.01;

// Main tube with inner bore and subtle end chamfers
module neoprene_tube() {
    difference() {
        // Outer body (along X)
        rotate([0,90,0])
            cylinder(h=tube_length, r=outer_r, center=true);

        // Inner bore (extends beyond ends to guarantee through-hole)
        rotate([0,90,0])
            cylinder(h=tube_length + 2*overlap, r=inner_r, center=true);

        // End chamfer cuts (ring frustums) — remove only the outer edge, keep bore open
        // +X end
        translate([ tube_length/2 - ch/2, 0, 0])
            rotate([0,90,0])
                difference() {
                    cylinder(h=ch + overlap, r1=outer_r + overlap, r2=outer_r - ch, center=true);
                    cylinder(h=ch + 3*overlap, r=inner_r - eps, center=true);
                }

        // -X end
        translate([-tube_length/2 + ch/2, 0, 0])
            rotate([0,90,0])
                difference() {
                    cylinder(h=ch + overlap, r1=outer_r - ch, r2=outer_r + overlap, center=true);
                    cylinder(h=ch + 3*overlap, r=inner_r - eps, center=true);
                }
    }
}

// Final Output
color([0.2, 0.2, 0.2])
neoprene_tube();