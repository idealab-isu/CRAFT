$fn=96;

// Ruideng-style panel meter / power supply module (generic approximation)
// Units: mm

// ---------- Parameters ----------
module_w = 71.0;
module_h = 39.0;
module_d = 24.0;

front_bezel_th = 2.2;
front_bezel_overhang = 1.2;

screen_w = 50.0;
screen_h = 22.0;
screen_inset = 0.8;

button_d = 6.0;
button_h = 1.2;
button_spacing = 10.0;
button_row_y = -10.5;

corner_r = 2.2;

mount_hole_d = 3.2;
mount_hole_inset_x = 6.0;
mount_hole_inset_y = 6.0;

rear_connector_w = 18.0;
rear_connector_h = 10.0;
rear_connector_d = 8.0;

terminal_block_w = 28.0;
terminal_block_h = 12.0;
terminal_block_d = 10.0;

vent_slot_w = 1.6;
vent_slot_h = 10.0;
vent_slot_pitch = 3.2;
vent_slot_count = 10;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module countersunk_hole(d=3.2, depth=10, cs_d=6.2, cs_h=1.6){
    union(){
        cylinder(d=d, h=depth, center=false);
        translate([0,0,depth-cs_h])
            cylinder(d1=cs_d, d2=d, h=cs_h, center=false);
    }
}

// ---------- Model ----------
module ruideng_panel_meter(){
    // Body
    color([0.15,0.15,0.16])
    difference(){
        // main body
        rounded_box(module_w, module_h, module_d, corner_r);

        // front recess for bezel lip
        translate([0,0,module_d-front_bezel_th])
            linear_extrude(height=front_bezel_th+0.01)
                offset(delta=-front_bezel_overhang)
                    rounded_rect_2d(module_w, module_h, corner_r);

        // mounting holes (through)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(module_w/2-mount_hole_inset_x), sy*(module_h/2-mount_hole_inset_y), 0])
                cylinder(d=mount_hole_d, h=module_d+0.2, center=false);
        }

        // side vent slots (left)
        for(i=[0:vent_slot_count-1]){
            y = (i-(vent_slot_count-1)/2)*vent_slot_pitch;
            translate([-module_w/2-0.01, y, module_d*0.35])
                rotate([0,90,0])
                    cube([vent_slot_h, vent_slot_w, 2.5], center=true);
        }
        // side vent slots (right)
        for(i=[0:vent_slot_count-1]){
            y = (i-(vent_slot_count-1)/2)*vent_slot_pitch;
            translate([ module_w/2+0.01, y, module_d*0.35])
                rotate([0,90,0])
                    cube([vent_slot_h, vent_slot_w, 2.5], center=true);
        }

        // rear connector cavity
        translate([0, module_h*0.18, -0.01])
            cube([rear_connector_w, rear_connector_h, rear_connector_d+0.02], center=true);

        // rear terminal block cavity
        translate([0, -module_h*0.22, -0.01])
            cube([terminal_block_w, terminal_block_h, terminal_block_d+0.02], center=true);
    }

    // Front bezel (slightly larger)
    color([0.10,0.10,0.11])
    translate([0,0,module_d-front_bezel_th])
    difference(){
        linear_extrude(height=front_bezel_th)
            rounded_rect_2d(module_w+2*front_bezel_overhang, module_h+2*front_bezel_overhang, corner_r+0.8);

        // inner opening to reveal face
        translate([0,0,-0.01])
            linear_extrude(height=front_bezel_th+0.02)
                rounded_rect_2d(module_w-1.0, module_h-1.0, corner_r);
    }

    // Screen window
    color([0.02,0.02,0.02])
    translate([0, 6.0, module_d-front_bezel_th-screen_inset])
        linear_extrude(height=0.8)
            rounded_rect_2d(screen_w, screen_h, 1.2);

    // Screen "glass"
    color([0.05,0.10,0.12, 0.65])
    translate([0, 6.0, module_d-front_bezel_th-0.2])
        linear_extrude(height=0.25)
            rounded_rect_2d(screen_w-1.0, screen_h-1.0, 1.0);

    // Buttons (3)
    for(k=[-1,0,1]){
        color([0.20,0.20,0.22])
        translate([k*button_spacing, button_row_y, module_d-front_bezel_th-0.2])
            cylinder(d=button_d, h=button_h, center=false);

        color([0.12,0.12,0.13])
        translate([k*button_spacing, button_row_y, module_d-front_bezel_th-0.2+button_h])
            cylinder(d=button_d-1.0, h=0.35, center=false);
    }

    // Rear connector blocks (visual)
    color([0.18,0.18,0.19])
    translate([0, module_h*0.18, 0])
        cube([rear_connector_w-1.0, rear_connector_h-1.0, rear_connector_d], center=true);

    color([0.12,0.45,0.12])
    translate([0, -module_h*0.22, 0])
        cube([terminal_block_w-1.0, terminal_block_h-1.0, terminal_block_d], center=true);

    // Terminal screw hints
    for(x=[-9,0,9]){
        color([0.55,0.55,0.55])
        translate([x, -module_h*0.22, terminal_block_d/2-1.2])
            cylinder(d=4.0, h=1.2, center=false);
        color([0.35,0.35,0.35])
        translate([x, -module_h*0.22, terminal_block_d/2-0.6])
            rotate([0,0,45])
                cube([3.2,0.8,0.6], center=true);
    }
}

// ---------- Render ----------
ruidend_panel_meter();