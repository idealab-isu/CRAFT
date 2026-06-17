$fn=96;

// Generic "component" placeholder: a small mounting block with a through-hole and a counterbore.
module component(
    L=60, W=30, H=12,
    hole_d=6,
    counterbore_d=12,
    counterbore_depth=4,
    fillet_r=2
){
    difference(){
        // Body with softened edges via minkowski (simple fillet approximation)
        minkowski(){
            translate([fillet_r, fillet_r, fillet_r])
                cube([L-2*fillet_r, W-2*fillet_r, H-2*fillet_r], center=false);
            sphere(r=fillet_r);
        }

        // Through hole (centered)
        translate([L/2, W/2, -1])
            cylinder(d=hole_d, h=H+2);

        // Counterbore on top
        translate([L/2, W/2, H-counterbore_depth])
            cylinder(d=counterbore_d, h=counterbore_depth+1);
    }
}

component();