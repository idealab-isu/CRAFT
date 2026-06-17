$fn=96;

module ht32_cap(
    outer_d=40,
    inner_d=32.4,
    height=28,
    wall=3.2,
    top_th=3.0,
    lip_h=10,
    lip_th=1.2,
    chamfer=1.2
){
    difference(){
        union(){
            // Outer body
            cylinder(d=outer_d, h=height, center=true);

            // Small outer grip ring
            translate([0,0, height/2 - 6])
                cylinder(d=outer_d+2.0, h=4, center=true);

            // Bottom chamfer ring (outer)
            translate([0,0, -height/2 + chamfer/2])
                cylinder(d1=outer_d-2*chamfer, d2=outer_d, h=chamfer, center=true);
        }

        // Main cavity (open at bottom)
        translate([0,0, -height/2 + (height-top_th)/2])
            cylinder(d=inner_d, h=height-top_th, center=true);

        // Inner lead-in chamfer at opening
        translate([0,0, -height/2 + chamfer/2])
            cylinder(d1=inner_d+2*chamfer, d2=inner_d, h=chamfer, center=true);

        // Inner retention lip (slight constriction near opening)
        translate([0,0, -height/2 + lip_h/2])
            cylinder(d=inner_d-2*lip_th, h=lip_h, center=true);
    }
}

ht32_cap();