$fn=96;

// Ring terminal parameters (mm)
ring_outer_d = 16;
ring_inner_d = 8;
ring_thickness = 2.2;

neck_length = 10;
neck_width  = 7;
neck_thickness = ring_thickness;

barrel_length = 18;
barrel_outer_d = 7.5;
barrel_inner_d = 4.2;

flare_length = 4;          // transition from neck to barrel
flare_width  = 8.5;        // width at barrel end of flare

// Small edge rounding (visual)
edge_chamfer = 0.6;

module chamfered_plate_2d(w, l, c){
    // 2D rectangle with chamfered corners (approx)
    c2 = min(c, min(w,l)/2 - 0.01);
    polygon(points=[
        [-w/2 + c2, -l/2],
        [ w/2 - c2, -l/2],
        [ w/2, -l/2 + c2],
        [ w/2,  l/2 - c2],
        [ w/2 - c2,  l/2],
        [-w/2 + c2,  l/2],
        [-w/2,  l/2 - c2],
        [-w/2, -l/2 + c2]
    ]);
}

module ring_terminal(){
    union(){
        // Ring pad
        difference(){
            cylinder(h=ring_thickness, d=ring_outer_d);
            translate([0,0,-0.2]) cylinder(h=ring_thickness+0.4, d=ring_inner_d);
        }

        // Neck (flat strap)
        translate([0, (ring_outer_d/2) + neck_length/2 - 0.2, 0])
            linear_extrude(height=neck_thickness)
                chamfered_plate_2d(neck_width, neck_length, edge_chamfer);

        // Flare transition (flat)
        translate([0, (ring_outer_d/2) + neck_length - 0.2 + flare_length/2, 0])
            linear_extrude(height=neck_thickness)
                polygon(points=[
                    [-neck_width/2, -flare_length/2],
                    [ neck_width/2, -flare_length/2],
                    [ flare_width/2,  flare_length/2],
                    [-flare_width/2,  flare_length/2]
                ]);

        // Barrel (tube) aligned along +Y
        translate([0, (ring_outer_d/2) + neck_length - 0.2 + flare_length - 0.2 + barrel_length/2, ring_thickness/2])
            rotate([90,0,0])
                difference(){
                    cylinder(h=barrel_length, d=barrel_outer_d, center=true);
                    cylinder(h=barrel_length+0.6, d=barrel_inner_d, center=true);
                }

        // Small fillet-like gussets between flare and barrel (simple wedges)
        for (sx=[-1,1]){
            translate([sx*(flare_width/2 - 0.8), (ring_outer_d/2) + neck_length - 0.2 + flare_length - 0.2, 0])
                hull(){
                    translate([0,0,0])
                        cube([1.6, 1.6, ring_thickness], center=false);
                    translate([sx*0.2, 3.0, ring_thickness/2])
                        rotate([90,0,0])
                            cylinder(h=1.6, d=2.2, center=false);
                }
        }
    }
}

ring_terminal();