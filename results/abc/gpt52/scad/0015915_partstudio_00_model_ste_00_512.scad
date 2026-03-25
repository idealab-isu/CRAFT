$fn=64;

plate_x = 0.2;
plate_y = 0.1;
plate_t = 0.01;

frame_w = 0.01;

grid_cols = 3;
grid_rows = 2;

gap_x = 0.01;
gap_y = 0.01;

cut_rx = 0.008;
cut_ry = 0.008;

rib_w = 0.008;
rib_t = plate_t;

module rounded_rect_2d(w, h, r){
    r2 = min(r, w/2, h/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_rect_prism(w, h, r, t){
    linear_extrude(height=t, center=true)
        rounded_rect_2d(w, h, r);
}

module base_plate(){
    rounded_rect_prism(plate_x, plate_y, 0.006, plate_t);
}

module frame_ring(){
    difference(){
        rounded_rect_prism(plate_x, plate_y, 0.006, plate_t);
        rounded_rect_prism(plate_x - 2*frame_w, plate_y - 2*frame_w, 0.004, plate_t + 0.002);
    }
}

module cutout_grid(){
    inner_x = plate_x - 2*frame_w;
    inner_y = plate_y - 2*frame_w;

    cell_w = (inner_x - (grid_cols+1)*gap_x)/grid_cols;
    cell_h = (inner_y - (grid_rows+1)*gap_y)/grid_rows;

    cut_w = cell_w;
    cut_h = cell_h;

    for (r=[0:grid_rows-1]){
        for (c=[0:grid_cols-1]){
            x = -inner_x/2 + gap_x + cut_w/2 + c*(cut_w + gap_x);
            y = -inner_y/2 + gap_y + cut_h/2 + r*(cut_h + gap_y);
            translate([x, y, 0])
                rounded_rect_prism(cut_w, cut_h, min(cut_rx, cut_ry, cut_w/2, cut_h/2), plate_t + 0.002);
        }
    }
}

module rib_diag(angle_deg){
    len = sqrt(plate_x*plate_x + plate_y*plate_y) + 0.05;
    rotate([0,0,angle_deg])
        cube([len, rib_w, rib_t], center=true);
}

module ribs(){
    union(){
        rib_diag(atan2(plate_y, plate_x));
        rib_diag(-atan2(plate_y, plate_x));
    }
}

module panel(){
    difference(){
        union(){
            frame_ring();
            intersection(){
                base_plate();
                ribs();
            }
        }
        cutout_grid();
    }
}

panel();