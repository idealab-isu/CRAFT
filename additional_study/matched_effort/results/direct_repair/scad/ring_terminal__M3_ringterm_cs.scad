$fn=96;

// Ring terminal parameters (mm)
ring_outer_d = 18;
ring_inner_d = 8;

tongue_len   = 22;
tongue_w     = 10;
tongue_th    = 2.2;

wire_barrel_len = 14;
wire_barrel_od  = 7.5;
wire_barrel_id  = 4.2;

transition_len = 6;   // between tongue and barrel
transition_w2  = 9;   // width near barrel

// Small edge rounding (visual)
edge_r = 0.6;

module rounded_plate_2d(len, w, r){
    r2 = min(r, w/2, len/2);
    hull(){
        translate([ r2,  r2]) circle(r=r2);
        translate([len-r2,  r2]) circle(r=r2);
        translate([len-r2, w-r2]) circle(r=r2);
        translate([ r2, w-r2]) circle(r=r2);
    }
}

module tongue_with_ring(){
    // Tongue base with rounded corners
    difference(){
        linear_extrude(height=tongue_th)
            translate([0, -tongue_w/2])
                rounded_plate_2d(tongue_len, tongue_w, edge_r);

        // Ring hole
        translate([0,0,-1])
            cylinder(h=tongue_th+2, d=ring_inner_d);

        // Outer ring shaping (keep material only within outer ring near the eye)
        // Intersect tongue with outer ring disk to form the eye area
    }

    // Add eye reinforcement disk (outer ring)
    difference(){
        cylinder(h=tongue_th, d=ring_outer_d);
        translate([0,0,-1]) cylinder(h=tongue_th+2, d=ring_inner_d);
    }

    // Blend tongue into eye by adding a small fillet-like hull
    hull(){
        translate([0,0,0]) cylinder(h=tongue_th, d=ring_outer_d);
        translate([ring_outer_d/2,0,0])
            linear_extrude(height=tongue_th)
                translate([0,-tongue_w/2])
                    square([0.01, tongue_w], center=false);
    }
}

module transition_block(){
    // A tapered transition from tongue width to near-barrel width
    linear_extrude(height=tongue_th)
        polygon(points=[
            [tongue_len, -tongue_w/2],
            [tongue_len,  tongue_w/2],
            [tongue_len+transition_len,  transition_w2/2],
            [tongue_len+transition_len, -transition_w2/2]
        ]);
}

module barrel(){
    // Cylindrical crimp barrel aligned with tongue centerline
    translate([tongue_len+transition_len + wire_barrel_len/2, 0, tongue_th/2])
    rotate([0,90,0])
    difference(){
        cylinder(h=wire_barrel_len, d=wire_barrel_od, center=true);
        cylinder(h=wire_barrel_len+2, d=wire_barrel_id, center=true);
    }
}

module ring_terminal(){
    union(){
        tongue_with_ring();
        transition_block();
        barrel();
    }
}

ring_terminal();