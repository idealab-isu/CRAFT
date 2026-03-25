$fn=64;

rail_w = 12.0;
rail_h = 8.0;
rail_l = 100.0;

top_w = 8.0;
top_h = 2.0;

side_w = (rail_w - top_w)/2;

hole_d = 3.2;
csk_d = 6.0;
csk_h = 1.5;
hole_pitch = 25.0;
hole_count = 4;

edge_margin = 12.5;

module mounting_hole(z0, through_h, d_through, d_csk, h_csk){
    union(){
        translate([0,0,z0]) cylinder(d=d_through, h=through_h);
        translate([0,0,z0 + through_h - h_csk]) cylinder(d1=d_csk, d2=d_through, h=h_csk);
    }
}

module rail_body(){
    union(){
        translate([0,0,0]) cube([rail_w, rail_l, rail_h], center=true);
        translate([0,0,(rail_h/2 + top_h/2)]) cube([top_w, rail_l, top_h], center=true);
    }
}

module rail_profile_cut(){
    union(){
        translate([0,0,(rail_h/2 - 1.2)]) cube([rail_w-1.0, rail_l+0.2, 2.4], center=true);
        translate([0,0,(rail_h/2 - 2.6)]) cube([rail_w-3.0, rail_l+0.2, 2.0], center=true);
    }
}

module guide_rail(){
    difference(){
        rail_body();
        rail_profile_cut();
        for(i=[0:hole_count-1]){
            y = -rail_l/2 + edge_margin + i*hole_pitch;
            translate([0,y,-rail_h/2]) mounting_hole(0, rail_h + top_h + 0.2, hole_d, csk_d, csk_h);
        }
    }
}

guide_rail();