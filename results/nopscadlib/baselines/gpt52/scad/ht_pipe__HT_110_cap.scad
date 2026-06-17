$fn=96;

module ht110_cap(
    od=110,
    wall=3.2,
    height=55,
    top_thickness=4,
    lip_height=22,
    lip_thickness=2.2,
    chamfer=1.2
){
    id = od - 2*wall;
    outer_r = od/2;
    inner_r = id/2;

    module chamfered_cyl(r, h, c){
        union(){
            cylinder(r=r, h=h-c);
            translate([0,0,h-c]) cylinder(r1=r, r2=max(r-c,0.01), h=c);
        }
    }

    difference(){
        union(){
            chamfered_cyl(outer_r, height, chamfer);

            translate([0,0,top_thickness])
                difference(){
                    cylinder(r=inner_r + lip_thickness, h=lip_height);
                    cylinder(r=inner_r, h=lip_height);
                }
        }

        translate([0,0,top_thickness])
            chamfered_cyl(inner_r, height, chamfer);

        translate([0,0,-0.2])
            cylinder(r=inner_r, h=top_thickness+0.4);
    }
}

translate([0,0,-55/2]) ht110_cap();