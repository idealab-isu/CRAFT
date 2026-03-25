$fn=96;

L=3.1;
W=1.6;
H=0.5;

corner_clip=0.28;      // plan corner bevel
edge_chamfer=0.08;     // outer edge chamfer (top/bottom)
panel_margin=0.22;     // inset from outer perimeter to panel opening
panel_depth=0.12;      // recess depth from top
border_width=0.12;     // raised border width around recessed panel
border_height=0.06;    // border rise above top face
panel_corner_clip=0.18;// angled corner cuts inside panel

module oct2d(l,w,c){
    polygon(points=[
        [ l/2-c,  w/2],
        [ l/2,    w/2-c],
        [ l/2,   -w/2+c],
        [ l/2-c, -w/2],
        [-l/2+c, -w/2],
        [-l/2,   -w/2+c],
        [-l/2,    w/2-c],
        [-l/2+c,  w/2]
    ]);
}

module plate_body(){
    // main body with chamfered top/bottom edges via hull of two extrusions
    hull(){
        translate([0,0,-H/2+edge_chamfer])
            linear_extrude(height=H-2*edge_chamfer)
                oct2d(L,W,corner_clip);
        translate([0,0,-H/2])
            linear_extrude(height=0.001)
                offset(delta=-edge_chamfer)
                    oct2d(L,W,corner_clip);
        translate([0,0,H/2-0.001])
            linear_extrude(height=0.001)
                offset(delta=-edge_chamfer)
                    oct2d(L,W,corner_clip);
    }
}

module recessed_panel_cut(){
    l2 = L - 2*panel_margin;
    w2 = W - 2*panel_margin;
    c2 = max(0.01, corner_clip*0.55);
    translate([0,0,H/2 - panel_depth])
        linear_extrude(height=panel_depth+0.02)
            oct2d(l2,w2,c2);
}

module border_ring(){
    l2 = L - 2*panel_margin;
    w2 = W - 2*panel_margin;
    c2 = max(0.01, corner_clip*0.55);

    l3 = l2 - 2*border_width;
    w3 = w2 - 2*border_width;
    c3 = max(0.01, c2*0.7);

    difference(){
        translate([0,0,H/2])
            linear_extrude(height=border_height)
                oct2d(l2,w2,c2);
        translate([0,0,H/2-0.01])
            linear_extrude(height=border_height+0.02)
                oct2d(l3,w3,c3);
    }
}

module panel_corner_cuts(){
    l2 = L - 2*panel_margin;
    w2 = W - 2*panel_margin;
    c2 = max(0.01, corner_clip*0.55);

    l3 = l2 - 2*border_width;
    w3 = w2 - 2*border_width;
    c3 = max(0.01, c2*0.7);

    // apply to inner panel area (inside border), cutting angled corners
    z0 = H/2 - panel_depth - 0.01;
    zh = panel_depth + border_height + 0.04;

    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(l3/2 - c3), sy*(w3/2 - c3), z0])
            rotate([0,0,45])
                cube([panel_corner_clip, panel_corner_clip, zh], center=true);
    }
}

difference(){
    union(){
        plate_body();
        border_ring();
    }
    recessed_panel_cut();
    panel_corner_cuts();
}