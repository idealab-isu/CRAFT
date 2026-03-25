$fn=64;

size_x = 0.1;
size_y = 0.1;
size_z = 0.02;

corner_r = 0.02;

recess_depth = 0.004;
recess_margin = 0.012;
recess_r = 0.012;

tab_count = 5;
tab_w = 0.010;
tab_d = 0.020;
tab_h = 0.006;
tab_gap = 0.006;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_block(w,h,z,r){
    linear_extrude(height=z, center=true)
        rounded_rect_2d(w,h,r);
}

module recessed_pattern(w,h,depth,margin,r){
    inner_w = max(0.001, w - 2*margin);
    inner_h = max(0.001, h - 2*margin);
    translate([0,0, size_z/2 - depth/2])
        linear_extrude(height=depth, center=true)
            rounded_rect_2d(inner_w, inner_h, r);
}

module cross_recess(w,h,depth,bar_w){
    translate([0,0, size_z/2 - depth/2])
        union(){
            cube([w*0.70, bar_w, depth], center=true);
            cube([bar_w, h*0.70, depth], center=true);
        }
}

module tabs_row(count, tab_w, tab_d, tab_h, gap){
    total_w = count*tab_w + (count-1)*gap;
    for(i=[0:count-1]){
        x = -total_w/2 + tab_w/2 + i*(tab_w+gap);
        translate([x, -size_y/2 + tab_d/2, -size_z/2 - tab_h/2])
            cube([tab_w, tab_d, tab_h], center=true);
    }
}

difference(){
    union(){
        rounded_block(size_x, size_y, size_z, corner_r);
        tabs_row(tab_count, tab_w, tab_d, tab_h, tab_gap);
    }
    union(){
        recessed_pattern(size_x, size_y, recess_depth, recess_margin, recess_r);
        cross_recess(size_x, size_y, recess_depth*0.9, bar_w=0.010);
    }
}