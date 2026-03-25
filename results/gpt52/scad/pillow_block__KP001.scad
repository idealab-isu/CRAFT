$fn=96;

shaft_d = 12.0;
base_x = 71.0;
base_y = 56.0;

base_th = 10.0;

ped_w = 44.0;
ped_d = 34.0;
ped_h = 26.0;

boss_d = 40.0;
boss_len = ped_w;

bearing_od = 32.0;
bearing_len = 14.0;

bolt_d = 8.5;
bolt_head_d = 16.0;
bolt_head_h = 3.0;

bolt_x = 52.0;
bolt_y = 36.0;

edge_r = 3.0;

module rounded_box(size=[10,10,10], r=2, center=true){
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, min(x,y)/2);
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    linear_extrude(height=z)
        offset(r=r2)
            offset(delta=-r2)
                square([x,y], center=false);
}

module bolt_hole_through(){
    union(){
        cylinder(d=bolt_d, h=base_th + ped_h + 2, center=true);
        translate([0,0, base_th/2 - bolt_head_h/2 + 0.01])
            cylinder(d=bolt_head_d, h=bolt_head_h, center=true);
    }
}

module pillow_block(){
    difference(){
        union(){
            rounded_box([base_x, base_y, base_th], r=edge_r, center=true);

            translate([0,0,(base_th+ped_h)/2])
                rounded_box([ped_w, ped_d, ped_h], r=2.5, center=true);

            translate([0,0,(base_th+ped_h)/2])
                rotate([0,90,0])
                    cylinder(d=boss_d, h=boss_len, center=true);
        }

        translate([0,0,(base_th+ped_h)/2])
            rotate([0,90,0])
                cylinder(d=bearing_od, h=boss_len + 2, center=true);

        translate([0,0,(base_th+ped_h)/2])
            rotate([0,90,0])
                cylinder(d=shaft_d, h=boss_len + 4, center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*bolt_x/2, sy*bolt_y/2, 0])
                bolt_hole_through();
        }
    }
}

pillow_block();