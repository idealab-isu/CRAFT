$fn = 96;

// Bi-metal saw blade (sheet model)
blade_len = 300;          // mm
blade_height = 20;        // mm
blade_thickness = 0.9;    // mm (sheet thickness)

tooth_pitch = 3.0;        // mm (distance between tooth tips)
tooth_height = 3.0;       // mm (tooth protrusion)
tooth_set = 0.25;         // mm (alternating lateral set)
tooth_tip_flat = 0.35;    // mm (flat at tooth tip)

back_round_r = 1.2;       // mm (rounding on back edge)
end_round_r = 2.0;        // mm (rounding on ends)

hole_d = 6.5;             // mm
hole_edge_margin = 12;    // mm from each end
hole_y = blade_height*0.62;

bimetal_strip_h = 4.0;    // mm (hardened tooth strip height)
bimetal_strip_inset = 0.0;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ r2, r2]) circle(r=r2);
        translate([ w-r2, r2]) circle(r=r2);
        translate([ r2, h-r2]) circle(r=r2);
        translate([ w-r2, h-r2]) circle(r=r2);
    }
}

module blade_body_2d(){
    difference(){
        rounded_rect_2d(blade_len, blade_height, end_round_r);
        // holes
        translate([hole_edge_margin, hole_y]) circle(d=hole_d);
        translate([blade_len-hole_edge_margin, hole_y]) circle(d=hole_d);
    }
}

module teeth_2d(){
    // Teeth along bottom edge (y=0), extending downward (negative y)
    n = floor(blade_len/tooth_pitch);
    for(i=[0:n-1]){
        x0 = i*tooth_pitch;
        x1 = x0 + tooth_pitch;
        xm = (x0+x1)/2;

        // tooth polygon with small flat tip
        tip_half = tooth_tip_flat/2;
        poly = [
            [x0, 0],
            [xm - tip_half, -tooth_height],
            [xm + tip_half, -tooth_height],
            [x1, 0]
        ];
        polygon(points=poly);
    }
}

module blade_profile_2d(){
    // Main blade plus teeth, with a slightly rounded back edge
    union(){
        blade_body_2d();
        teeth_2d();
        // back edge rounding (subtle bulge) via Minkowski on a thin strip
        // Keep it light to remain "sheet-like"
        translate([0, blade_height-back_round_r*2])
            minkowski(){
                square([blade_len, back_round_r*2], center=false);
                circle(r=back_round_r);
            }
    }
}

module bimetal_strip_2d(){
    // Strip near toothed edge (bottom), inside blade height
    // Positioned from y=0 up to bimetal_strip_h
    translate([0+bimetal_strip_inset, 0])
        square([blade_len-2*bimetal_strip_inset, bimetal_strip_h], center=false);
}

module saw_blade(){
    // Base blade (sheet)
    color([0.75,0.75,0.78])
    linear_extrude(height=blade_thickness, center=true)
        difference(){
            blade_profile_2d();
            // ensure holes cut through teeth area too (already in body, but keep consistent)
            translate([hole_edge_margin, hole_y]) circle(d=hole_d);
            translate([blade_len-hole_edge_margin, hole_y]) circle(d=hole_d);
        }

    // Bi-metal tooth strip overlay (slightly different color)
    color([0.55,0.55,0.60])
    translate([0,0,blade_thickness/2 + 0.01])
        linear_extrude(height=0.12, center=false)
            intersection(){
                bimetal_strip_2d();
                blade_profile_2d();
            }

    // Alternating tooth set (tiny lateral offsets on tooth tips)
    // Represented as thin raised facets on alternating teeth
    set_h = 0.08;
    n = floor(blade_len/tooth_pitch);
    for(i=[0:n-1]){
        x0 = i*tooth_pitch;
        x1 = x0 + tooth_pitch;
        xm = (x0+x1)/2;
        tip_half = tooth_tip_flat/2;

        // small cap at tooth tip
        cap_w = max(tooth_tip_flat, 0.5);
        cap_h = 0.6;
        side = (i%2==0) ? 1 : -1;

        color([0.45,0.45,0.50])
        translate([xm - cap_w/2, -tooth_height - cap_h, 0])
            translate([side*tooth_set, 0, blade_thickness/2 + 0.02])
                linear_extrude(height=set_h, center=false)
                    square([cap_w, cap_h], center=false);
    }
}

saw_blade();