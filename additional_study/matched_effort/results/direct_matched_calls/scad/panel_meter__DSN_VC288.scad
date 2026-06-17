$fn=96;

// DSN-DC 100V 10A panel volt/ammeter (approximate model)
// Units: mm

// ---------- Parameters ----------
body_w = 48.0;
body_h = 29.0;
body_d = 22.0;

bezel_w = 50.0;
bezel_h = 31.0;
bezel_t = 2.2;

corner_r = 2.2;

screen_w = 36.0;
screen_h = 14.0;
screen_inset = 0.8;

face_recess = 0.6; // slight recess for screen area

// Rear features (approximate)
rear_step_w = 44.0;
rear_step_h = 25.0;
rear_step_d = 6.0;

terminal_block_w = 18.0;
terminal_block_h = 10.0;
terminal_block_d = 8.0;

terminal_pitch = 5.0;
terminal_d = 2.2;
terminal_len = 6.0;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module bezel(){
    // Bezel plate with screen window
    difference(){
        rounded_box(bezel_w, bezel_h, bezel_t, corner_r+0.6);
        translate([0,0,-0.01])
            linear_extrude(height=bezel_t+0.02)
                rounded_rect_2d(screen_w, screen_h, 1.2);
    }
}

module body(){
    // Main body behind bezel
    translate([0,0,bezel_t])
        rounded_box(body_w, body_h, body_d, corner_r);
}

module face_recess_area(){
    // Slight recess around screen on the bezel face
    translate([0,0,bezel_t-face_recess])
        linear_extrude(height=face_recess+0.01)
            rounded_rect_2d(screen_w+6, screen_h+6, 2.0);
}

module screen_lens(){
    // Dark lens inset behind bezel window
    lens_t = 1.2;
    translate([0,0,bezel_t + screen_inset])
        color([0.05,0.05,0.06])
            linear_extrude(height=lens_t)
                rounded_rect_2d(screen_w-0.6, screen_h-0.6, 1.0);
}

module rear_step(){
    // Slight step on rear (approx)
    translate([0,0,bezel_t+body_d-rear_step_d])
        rounded_box(rear_step_w, rear_step_h, rear_step_d, 1.6);
}

module terminal_block(){
    // Terminal block on back
    z0 = bezel_t + body_d;
    translate([0, -body_h/2 + terminal_block_h/2 + 2.0, z0])
        color([0.15,0.15,0.15])
        difference(){
            rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.0);
            // terminal holes
            for(i=[-1.5,-0.5,0.5,1.5]){
                translate([i*terminal_pitch, 0, terminal_block_d/2])
                    rotate([90,0,0])
                        cylinder(d=terminal_d, h=terminal_block_h+2, center=true);
            }
        }
    // terminal pins (visual)
    for(i=[-1.5,-0.5,0.5,1.5]){
        translate([i*terminal_pitch, -body_h/2 + 2.0, z0 + terminal_block_d/2])
            color([0.75,0.65,0.25])
                rotate([90,0,0])
                    cylinder(d=terminal_d-0.4, h=terminal_len, center=false);
    }
}

module mounting_lips(){
    // Small side lips on bezel (approx)
    lip_w = 3.0;
    lip_h = 10.0;
    lip_t = 1.2;
    for(side=[-1,1]){
        translate([side*(bezel_w/2 - lip_w/2), 0, 0.6])
            color([0.12,0.12,0.12])
                rounded_box(lip_w, lip_h, lip_t, 0.8);
    }
}

module panel_meter(){
    color([0.12,0.12,0.12])
    union(){
        difference(){
            union(){
                bezel();
                body();
                mounting_lips();
            }
            // face recess around screen
            face_recess_area();
        }
        screen_lens();
        // rear details
        color([0.10,0.10,0.10]) rear_step();
        terminal_block();
    }
}

// ---------- Render ----------
panel_meter();