$fn=64;

rod_d = 10.0;
rod_r = rod_d/2;

bracket_h = 20.0;

base_len = 50.0;
base_w   = 30.0;
base_t   = 6.0;

wall_t   = 6.0;
outer_r  = rod_r + wall_t;          // 11mm
outer_d  = outer_r*2;

cap_t    = 6.0;                      // top thickness above rod center
center_z = base_t + outer_r;         // rod center height

slot_w   = 3.0;                      // clamp slit width
bolt_d   = 5.0;                      // M5 clearance
bolt_head_d = 9.5;                   // socket head clearance
bolt_head_h = 4.0;

bolt_x_offset = 10.0;                // from centerline
bolt_z = center_z + 2.0;             // slightly above center

module base_plate(){
    translate([-base_len/2, -base_w/2, 0])
        cube([base_len, base_w, base_t], center=false);
}

module saddle_block(){
    translate([0,0,base_t])
        cylinder(h=bracket_h-base_t, r=outer_r, center=false);
}

module rod_bore(){
    translate([0,0,center_z])
        rotate([90,0,0])
            cylinder(h=base_w+2, r=rod_r+0.2, center=true);
}

module clamp_slot(){
    translate([0,0,base_t])
        cube([slot_w, outer_d+2, bracket_h-base_t+1], center=true);
}

module bolt_hole(xpos){
    translate([xpos,0,bolt_z])
        rotate([90,0,0]){
            cylinder(h=base_w+2, r=bolt_d/2, center=true);
            translate([0, (base_w/2 - bolt_head_h/2), 0])
                cylinder(h=bolt_head_h, r=bolt_head_d/2, center=true);
        }
}

module bracket(){
    difference(){
        union(){
            base_plate();
            saddle_block();
        }
        rod_bore();
        clamp_slot();
        bolt_hole(-bolt_x_offset);
        bolt_hole( bolt_x_offset);
    }
}

translate([0,0,-bracket_h/2])
    bracket();