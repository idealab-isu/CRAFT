$fn=96;

plate_xy = 40;
plate_z  = 16;

corner_r = 6;

thin_z = 6;
thick_z = 16;
boss_len = 14;

slot_len = 10;
slot_w   = 4.2;
slot_r   = slot_w/2;
slot_dogbone_r = 1.6;

slot_rows_y = [-10, 0, 10];
slot_cols_x = [-10, 0, 10];

recess_d = 10;
recess_depth = 0.8;
recess_inset = 7.5;

notch_w = 6;
notch_h = 2.2;
notch_depth = 1.2;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module keyhole_slot_2d(L, W){
    r = W/2;
    union(){
        hull(){
            translate([-L/2 + r, 0]) circle(r=r);
            translate([ L/2 - r, 0]) circle(r=r);
        }
        translate([ L/2 - r, 0]) circle(r=r*1.35);
    }
}

module dogbone_slot_2d(L, W, rb){
    r = W/2;
    union(){
        hull(){
            translate([-L/2 + r, 0]) circle(r=r);
            translate([ L/2 - r, 0]) circle(r=r);
        }
        translate([-L/2 + r, 0]) circle(r=rb);
        translate([ L/2 - r, 0]) circle(r=rb);
    }
}

module slot_cut(x,y,rot=0){
    translate([x,y,0])
        rotate([0,0,rot])
            linear_extrude(height=plate_z+2, center=false)
                union(){
                    dogbone_slot_2d(slot_len, slot_w, slot_dogbone_r);
                    translate([0,0]) keyhole_slot_2d(slot_len*0.9, slot_w*0.95);
                };
}

module recess_ring(x,y,top=true){
    zpos = top ? (thin_z - recess_depth) : 0;
    translate([x,y,zpos])
        linear_extrude(height=recess_depth, center=false)
            difference(){
                circle(d=recess_d);
                circle(d=recess_d-1.2);
            };
}

module edge_notch(side=0){
    // side: 0=+X,1=-X,2=+Y,3=-Y
    if(side==0)
        translate([plate_xy/2 - notch_depth, 0, thin_z/2])
            cube([notch_depth+0.2, notch_w, notch_h], center=true);
    else if(side==1)
        translate([-plate_xy/2 + notch_depth, 0, thin_z/2])
            cube([notch_depth+0.2, notch_w, notch_h], center=true);
    else if(side==2)
        translate([0, plate_xy/2 - notch_depth, thin_z/2])
            cube([notch_w, notch_depth+0.2, notch_h], center=true);
    else
        translate([0, -plate_xy/2 + notch_depth, thin_z/2])
            cube([notch_w, notch_depth+0.2, notch_h], center=true);
}

module base_body(){
    union(){
        translate([0,0,0])
            linear_extrude(height=thin_z, center=false)
                rounded_rect_2d(plate_xy, plate_xy, corner_r);

        translate([plate_xy/2 - boss_len/2, 0, 0])
            linear_extrude(height=thick_z, center=false)
                rounded_rect_2d(boss_len, plate_xy, corner_r);
    }
}

difference(){
    translate([0,0,-plate_z/2])
        base_body();

    // Slots: 3 rows, 3 columns; alternate orientation by row
    for(iy=[0:len(slot_rows_y)-1]){
        y = slot_rows_y[iy];
        rot = (iy%2==0) ? 0 : 90;
        for(ix=[0:len(slot_cols_x)-1]){
            x = slot_cols_x[ix];
            translate([0,0,-plate_z/2-1])
                slot_cut(x,y,rot);
        }
    }

    // Edge notches at mid-sides
    translate([0,0,-plate_z/2])
        union(){
            edge_notch(0);
            edge_notch(1);
            edge_notch(2);
            edge_notch(3);
        }

    // Shallow circular recess outlines near corners (top face)
    translate([0,0,-plate_z/2])
        union(){
            recess_ring( plate_xy/2 - recess_inset,  plate_xy/2 - recess_inset, true);
            recess_ring(-plate_xy/2 + recess_inset,  plate_xy/2 - recess_inset, true);
            recess_ring( plate_xy/2 - recess_inset, -plate_xy/2 + recess_inset, true);
            recess_ring(-plate_xy/2 + recess_inset, -plate_xy/2 + recess_inset, true);
        }

    // Matching shallow recess outlines on bottom face
    translate([0,0,-plate_z/2])
        union(){
            translate([ plate_xy/2 - recess_inset,  plate_xy/2 - recess_inset, 0])
                linear_extrude(height=recess_depth, center=false)
                    difference(){ circle(d=recess_d); circle(d=recess_d-1.2); }
            translate([-plate_xy/2 + recess_inset,  plate_xy/2 - recess_inset, 0])
                linear_extrude(height=recess_depth, center=false)
                    difference(){ circle(d=recess_d); circle(d=recess_d-1.2); }
            translate([ plate_xy/2 - recess_inset, -plate_xy/2 + recess_inset, 0])
                linear_extrude(height=recess_depth, center=false)
                    difference(){ circle(d=recess_d); circle(d=recess_d-1.2); }
            translate([-plate_xy/2 + recess_inset, -plate_xy/2 + recess_inset, 0])
                linear_extrude(height=recess_depth, center=false)
                    difference(){ circle(d=recess_d); circle(d=recess_d-1.2); }
        }
}