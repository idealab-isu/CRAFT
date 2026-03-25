$fn=96;

module ht75_cap(
    od=75,
    wall=2.5,
    height=45,
    top_thickness=3,
    socket_depth=30,
    lip_height=6,
    lip_extra=2.0,
    chamfer=1.2
){
    id = od - 2*wall;
    outer_r = od/2;
    inner_r = id/2;

    module outer_shell(){
        union(){
            cylinder(h=height, r=outer_r);
            translate([0,0,height-lip_height])
                cylinder(h=lip_height, r=outer_r + lip_extra);
        }
    }

    module inner_void(){
        union(){
            translate([0,0,0])
                cylinder(h=socket_depth, r=inner_r);
            translate([0,0,0])
                cylinder(h=chamfer, r1=inner_r+chamfer, r2=inner_r);
        }
    }

    module top_relief(){
        translate([0,0,height-top_thickness])
            cylinder(h=top_thickness+0.2, r=inner_r);
    }

    translate([0,0,-height/2])
    difference(){
        outer_shell();
        inner_void();
        top_relief();
    }
}

ht75_cap();