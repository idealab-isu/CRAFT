$fn=96;

sx = 0.8;
sy = 0.8;
sz = 2.0;

ch = 0.08;          // vertical edge bevel amount
mid_bulge = 0.06;   // wider at mid-height
end_taper = 0.10;   // narrower at top/bottom
panel_inset = 0.05; // subtle inset panel depth
panel_margin = 0.12;

module chamfered_prism(w, d, h, c){
    linear_extrude(height=h, center=true)
        offset(delta=-c, chamfer=true)
            square([w, d], center=true);
}

module outer_body(){
    // Create a tapered/bulged profile along Z by hulling three chamfered sections
    union(){
        hull(){
            translate([0,0,-sz/2]) chamfered_prism(sx*(1-end_taper), sy*(1-end_taper), 0.02, ch);
            translate([0,0,0])      chamfered_prism(sx*(1+mid_bulge), sy*(1+mid_bulge), 0.02, ch);
        }
        hull(){
            translate([0,0,0])      chamfered_prism(sx*(1+mid_bulge), sy*(1+mid_bulge), 0.02, ch);
            translate([0,0, sz/2])  chamfered_prism(sx*(1-end_taper), sy*(1-end_taper), 0.02, ch);
        }
    }
}

module inset_panels(){
    // Subtract shallow recessed rectangles on the four side faces
    // Front/back
    for (s = [-1, 1]){
        translate([0, s*(sy/2 + 0.001), 0])
            rotate([90,0,0])
                linear_extrude(height=panel_inset, center=false)
                    square([sx - 2*panel_margin, sz - 2*panel_margin], center=true);
    }
    // Left/right
    for (s = [-1, 1]){
        translate([s*(sx/2 + 0.001), 0, 0])
            rotate([90,0,90])
                linear_extrude(height=panel_inset, center=false)
                    square([sy - 2*panel_margin, sz - 2*panel_margin], center=true);
    }
}

difference(){
    outer_body();
    inset_panels();
}