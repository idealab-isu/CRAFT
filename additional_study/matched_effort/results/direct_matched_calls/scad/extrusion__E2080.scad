$fn = 64;

// 20x80 aluminum extrusion-like profile (simplified), 100mm long
// Cross-section: 20.0mm x 80.0mm, with 4 longitudinal T-slots and a central bore.

length = 100;

w = 20;
h = 80;

// Outer corner radius (approx)
r_outer = 1.0;

// Central bore
bore_d = 5.2;

// Slot parameters (approx, for a typical T-slot look)
slot_open = 6.0;     // opening at surface
slot_neck = 8.0;     // neck width inside
slot_head = 12.0;    // undercut width
slot_depth = 6.0;    // depth from surface to head
slot_head_depth = 2.5; // additional depth for head undercut

// Internal lightening pockets (approx)
pocket_w = 10.0;
pocket_h = 30.0;
pocket_r = 1.0;

module rounded_rect_2d(W, H, R){
    R = min(R, W/2, H/2);
    hull(){
        translate([ W/2-R,  H/2-R]) circle(r=R);
        translate([-W/2+R,  H/2-R]) circle(r=R);
        translate([-W/2+R, -H/2+R]) circle(r=R);
        translate([ W/2-R, -H/2+R]) circle(r=R);
    }
}

module tslot_cut_2d(W, H, side="top"){
    // Creates a T-slot cut profile on one side of the rectangle.
    // side: "top","bottom","left","right"
    // Coordinates centered at origin.
    if (side == "top"){
        translate([0, H/2 - slot_depth/2])
            square([slot_open, slot_depth], center=true);
        translate([0, H/2 - slot_depth - slot_head_depth/2])
            square([slot_head, slot_head_depth], center=true);
        translate([0, H/2 - slot_depth - slot_head_depth - 2.0])
            square([slot_neck, 4.0], center=true);
    } else if (side == "bottom"){
        mirror([0,1,0]) tslot_cut_2d(W,H,"top");
    } else if (side == "left"){
        rotate(90) tslot_cut_2d(H,W,"top");
    } else if (side == "right"){
        rotate(-90) tslot_cut_2d(H,W,"top");
    }
}

module pocket_2d(cx, cy, pw, ph, pr){
    translate([cx, cy]) rounded_rect_2d(pw, ph, pr);
}

module profile_2d(){
    difference(){
        // Outer body
        rounded_rect_2d(w, h, r_outer);

        // Central bore
        circle(d=bore_d);

        // Four T-slots
        tslot_cut_2d(w,h,"top");
        tslot_cut_2d(w,h,"bottom");
        tslot_cut_2d(w,h,"left");
        tslot_cut_2d(w,h,"right");

        // Internal pockets (approximate)
        pocket_2d(0,  20, pocket_w, pocket_h, pocket_r);
        pocket_2d(0, -20, pocket_w, pocket_h, pocket_r);
    }
}

linear_extrude(height=length, center=false, convexity=10)
    profile_2d();