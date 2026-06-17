$fn=96;

module ht50_cap(
    od=56,          // outer diameter of cap body
    wall=2.2,       // wall thickness
    height=40,      // overall height
    top_th=3,       // top thickness
    socket_id=50.2, // inner diameter of socket (fits HT50 pipe OD)
    socket_depth=28,// insertion depth
    chamfer=1.2,    // lead-in chamfer
    grip_ribs=18,   // number of ribs
    rib_h=0.8,      // rib height
    rib_w=2.2       // rib width (tangential)
){
    id = od - 2*wall;
    outer_r = od/2;
    inner_r = id/2;

    module rib(){
        translate([outer_r - rib_h/2, 0, height*0.55])
            cube([rib_h, rib_w, height*0.7], center=true);
    }

    difference(){
        union(){
            cylinder(h=height, r=outer_r, center=true);

            // external grip ribs
            for(i=[0:grip_ribs-1]){
                rotate([0,0, i*360/grip_ribs]) rib();
            }
        }

        // main hollow (leaves top thickness)
        translate([0,0, -height/2 + top_th/2])
            cylinder(h=height-top_th, r=inner_r, center=true);

        // socket bore for pipe insertion
        translate([0,0, height/2 - socket_depth/2])
            cylinder(h=socket_depth+0.02, r=socket_id/2, center=true);

        // lead-in chamfer at opening
        translate([0,0, height/2 - chamfer/2])
            cylinder(h=chamfer+0.02, r1=socket_id/2 + chamfer, r2=socket_id/2, center=true);
    }
}

ht50_cap();