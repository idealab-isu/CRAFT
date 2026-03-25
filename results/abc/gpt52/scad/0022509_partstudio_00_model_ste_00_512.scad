$fn=64;

L = 100;
W = 40;
H = 12;

flange_overhang = 2;
flange_thk = 2;

wall_taper = 3;          // outward growth from bottom to top (per side)
bottom_margin = 3;       // bottom rim thickness around inner cavity

recess_depth = 2.5;
recess_margin = 6;

slot_len = 70;
slot_w = 4;
slot_depth = recess_depth + 1;

module frustum_box(size_bottom=[10,10,10], size_top=[12,12,10], h=10){
    hull(){
        translate([0,0,0]) cube([size_bottom[0], size_bottom[1], 0.01], center=true);
        translate([0,0,h]) cube([size_top[0], size_top[1], 0.01], center=true);
    }
}

module outer_shell(){
    union(){
        frustum_box(
            size_bottom=[L - 2*wall_taper, W - 2*wall_taper, H],
            size_top=[L, W, H],
            h=H
        );
        translate([0,0,H - flange_thk/2])
            cube([L + 2*flange_overhang, W + 2*flange_overhang, flange_thk], center=true);
    }
}

module inner_cavity(){
    frustum_box(
        size_bottom=[(L - 2*wall_taper) - 2*bottom_margin, (W - 2*wall_taper) - 2*bottom_margin, H],
        size_top=[L - 2*bottom_margin, W - 2*bottom_margin, H],
        h=H - flange_thk
    );
}

module recessed_panel_cut(){
    translate([0,0,H - flange_thk - recess_depth/2])
        cube([L - 2*recess_margin, W - 2*recess_margin, recess_depth], center=true);
}

module slot_cut(){
    translate([0,0,H - flange_thk - recess_depth + slot_depth/2])
        cube([slot_len, slot_w, slot_depth], center=true);
}

difference(){
    outer_shell();
    translate([0,0,(H - flange_thk)/2])
        inner_cavity();
    recessed_panel_cut();
    slot_cut();
}