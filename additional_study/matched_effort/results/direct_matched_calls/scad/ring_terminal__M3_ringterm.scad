$fn=128;

// Ring terminal parameters (mm)
ring_od        = 12;     // outer diameter of ring
ring_id        = 6.4;    // inner hole diameter (for screw)
ring_thickness = 1.6;    // thickness (Z)

neck_len       = 6;      // length from ring tangent to barrel start
neck_w         = 6.5;    // width of neck
neck_t         = ring_thickness;

barrel_len     = 14;     // crimp barrel length
barrel_od      = 6.0;    // barrel outer diameter
barrel_id      = 3.2;    // barrel inner diameter (wire entry)
barrel_taper   = 0.6;    // slight taper amount on OD along length

fillet_r       = 1.2;    // blend radius between ring and neck (approx)

// Helpers
module capsule2d(len, w){
    // 2D capsule centered at origin, length along X
    r = w/2;
    hull(){
        translate([-len/2 + r, 0]) circle(r=r);
        translate([ len/2 - r, 0]) circle(r=r);
    }
}

module ring_terminal(){
    difference(){
        union(){
            // Ring (washer)
            linear_extrude(height=ring_thickness)
                difference(){
                    circle(d=ring_od);
                    circle(d=ring_id);
                }

            // Neck (flat strap) blended into ring
            // Place neck so its left end overlaps ring slightly for a clean union
            translate([ring_od/2 - fillet_r, 0, 0])
                linear_extrude(height=neck_t)
                    capsule2d(neck_len + 2*fillet_r, neck_w);

            // Barrel (hollow cylinder) attached to neck end
            // Barrel axis along X, centered on neck centerline
            translate([ring_od/2 + neck_len, 0, ring_thickness/2])
                rotate([0,90,0])
                    difference(){
                        // Slight taper on OD using cylinder with different radii
                        cylinder(h=barrel_len, r1=barrel_od/2, r2=(barrel_od/2 - barrel_taper));
                        translate([0,0,-0.2])
                            cylinder(h=barrel_len+0.4, r=barrel_id/2);
                    }

            // Small transition block between neck and barrel for strength
            translate([ring_od/2 + neck_len - 1.0, 0, ring_thickness/2])
                rotate([0,90,0])
                    cylinder(h=2.0, r=neck_w/2);
        }

        // Flatten underside (ensure perfectly flat base)
        translate([-100, -100, -1])
            cube([200, 200, 1]);
    }
}

ring_terminal();