$fn = 128;

bore_d = 3.0;
od_d   = 6.0;
width  = 2.5;

// Simple representation: outer ring + inner ring (no balls/cage)
outer_ring_thickness = 0.6;  // radial thickness of outer ring
inner_ring_thickness = 0.6;  // radial thickness of inner ring

outer_r = od_d/2;
inner_bore_r = bore_d/2;

outer_ring_id_r = outer_r - outer_ring_thickness;
inner_ring_od_r = inner_bore_r + inner_ring_thickness;

module ring(r_outer, r_inner, h){
    difference(){
        cylinder(h=h, r=r_outer, center=true);
        cylinder(h=h+0.2, r=r_inner, center=true);
    }
}

union(){
    // Outer ring
    ring(outer_r, outer_ring_id_r, width);

    // Inner ring
    ring(inner_ring_od_r, inner_bore_r, width);
}