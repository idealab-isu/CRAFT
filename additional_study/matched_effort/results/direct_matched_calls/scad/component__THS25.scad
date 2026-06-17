$fn=96;

// Generic parametric component (mounting block with through-holes and a central pocket)
module component(
    L=60, W=30, H=12,
    corner_r=3,
    hole_d=4.2,
    hole_edge=6,
    pocket_L=30, pocket_W=14, pocket_D=5,
    chamfer=0.8
){
    difference() {
        // Main body with rounded corners
        linear_extrude(height=H)
            offset(r=corner_r)
                offset(delta=-corner_r)
                    square([L, W], center=true);

        // Through holes (4x)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(L/2 - hole_edge), sy*(W/2 - hole_edge), -0.5])
                cylinder(d=hole_d, h=H+1);
        }

        // Central pocket
        translate([0,0,H-pocket_D])
            linear_extrude(height=pocket_D+0.5)
                offset(r=1.5)
                    offset(delta=-1.5)
                        square([pocket_L, pocket_W], center=true);

        // Top chamfer (simple bevel via subtracting a slightly larger, shallow offset)
        translate([0,0,H-chamfer])
            linear_extrude(height=chamfer+0.2, scale=1.02)
                offset(r=corner_r+0.6)
                    offset(delta=-(corner_r+0.6))
                        square([L+1.2, W+1.2], center=true);
    }
}

component();