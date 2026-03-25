$fn=96;

L = 0.4;
W = 0.1;
H = 0.1;

ch = 0.01;          // chamfer size
panel_inset = 0.01; // inset from perimeter for recessed panel
panel_depth = 0.01; // depth of recess on broad faces

rib_w = 0.03;       // central rib width across W
rib_h = 0.01;       // rib height above arched top surface

arch_sag = 0.01;    // concave sag across width on top/bottom
arch_len = 0.12;    // length of arched region along X (centered)

module chamfered_block(l, w, h, c){
    difference(){
        cube([l,w,h], center=true);
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(l/2 - c/2), sy*(w/2 - c/2), sz*(h/2 - c/2)])
                rotate([0,0,45])
                    cube([c*sqrt(2), c*sqrt(2), c*sqrt(2)], center=true);
        }
    }
}

module recessed_panel_on_face(zsign=1){
    translate([0,0,zsign*(H/2 - panel_depth/2)])
        cube([L - 2*panel_inset, W - 2*panel_inset, panel_depth], center=true);
}

module arch_cut(zsign=1){
    // Creates a shallow concave curvature across width by subtracting a large cylinder
    // oriented along X, limited to a central length region.
    r = (W*W)/(8*arch_sag) + arch_sag/2;
    y0 = zsign*(r - arch_sag);
    intersection(){
        translate([0,0,0])
            cube([arch_len, W+0.2, H+0.2], center=true);
        translate([0, y0, 0])
            rotate([0,90,0])
                cylinder(r=r, h=arch_len+0.4, center=true);
    }
}

module central_rib(){
    translate([0,0,H/2 + rib_h/2])
        cube([L - 2*panel_inset, rib_w, rib_h], center=true);
}

difference(){
    union(){
        chamfered_block(L,W,H,ch);
        central_rib();
    }
    recessed_panel_on_face(1);
    recessed_panel_on_face(-1);
    translate([0,0,H/2]) arch_cut(1);
    translate([0,0,-H/2]) arch_cut(-1);
}