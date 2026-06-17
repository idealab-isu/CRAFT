$fn=128;

// Ring terminal parameters (mm)
ring_outer_d = 18;
ring_inner_d = 8;
ring_thickness = 2.2;

neck_length = 10;
neck_width  = 7;
neck_thickness = ring_thickness;

barrel_length = 18;
barrel_outer_d = 7.5;
barrel_inner_d = 4.2;

flare_length = 4;          // transition from neck to barrel
flare_width  = 9;          // wider at ring side

// Small edge softening (visual)
edge_chamfer = 0.4;

module chamfered_plate_2d(points, chamfer=0.4){
    // Simple 2D offset trick to soften corners
    // (offset in then out) keeps overall size close while rounding corners.
    offset(r=chamfer) offset(delta=-chamfer) polygon(points);
}

module ring_terminal(){
    union(){
        // Ring + neck as a single plate
        linear_extrude(height=ring_thickness)
        difference(){
            union(){
                // Ring
                circle(d=ring_outer_d);

                // Neck + flare (2D)
                // Neck extends in +X direction from ring center
                chamfered_plate_2d(
                    points=[
                        [ring_outer_d/2 - 0.2, -flare_width/2],
                        [ring_outer_d/2 + flare_length, -neck_width/2],
                        [ring_outer_d/2 + flare_length + neck_length, -neck_width/2],
                        [ring_outer_d/2 + flare_length + neck_length,  neck_width/2],
                        [ring_outer_d/2 + flare_length,  neck_width/2],
                        [ring_outer_d/2 - 0.2,  flare_width/2]
                    ],
                    chamfer=edge_chamfer
                );
            }

            // Ring hole
            circle(d=ring_inner_d);
        }

        // Barrel (crimp tube), centered on neck axis, attached at end of neck
        translate([ring_outer_d/2 + flare_length + neck_length + barrel_length/2, 0, ring_thickness/2])
        rotate([0,90,0])
        difference(){
            cylinder(h=barrel_length, d=barrel_outer_d, center=true);
            cylinder(h=barrel_length+0.5, d=barrel_inner_d, center=true);
        }

        // Small fillet-like collar between neck and barrel (visual)
        translate([ring_outer_d/2 + flare_length + neck_length, 0, 0])
        linear_extrude(height=ring_thickness)
        chamfered_plate_2d(
            points=[
                [0, -neck_width/2],
                [2.0, -barrel_outer_d/2],
                [2.0,  barrel_outer_d/2],
                [0,  neck_width/2]
            ],
            chamfer=edge_chamfer
        );
    }
}

ring_terminal();