$fn=64;

// Peacefair PZEM-001 AC digital multi-function meter (approximate model)
// Units: mm

// ---------- Parameters ----------
body_w = 80.0;
body_h = 43.0;
body_d = 25.0;

front_bezel_w = 85.0;
front_bezel_h = 48.0;
front_bezel_t = 3.0;

corner_r = 2.5;

screen_w = 60.0;
screen_h = 26.0;
screen_inset = 1.2;

screen_margin_top = 7.0;   // from top of bezel
screen_margin_left = (front_bezel_w - screen_w)/2;

button_d = 6.0;
button_h = 2.0;
button_offset_y = 8.0;     // from bottom of bezel
button_spacing = 12.0;

terminal_block_w = 78.0;
terminal_block_h = 12.0;
terminal_block_d = 10.0;
terminal_block_offset_from_back = 2.0; // protrusion beyond back

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ -w/2 + r2, -h/2 + r2 ]) circle(r=r2);
        translate([  w/2 - r2, -h/2 + r2 ]) circle(r=r2);
        translate([ -w/2 + r2,  h/2 - r2 ]) circle(r=r2);
        translate([  w/2 - r2,  h/2 - r2 ]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module screw_terminal_block(){
    // Simple representation: block + 6 screw holes
    holes = 6;
    hole_r = 1.6;
    hole_pitch = terminal_block_w/(holes+1);
    difference(){
        translate([0,0,0])
            rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 1.2);
        for(i=[1:holes]){
            x = -terminal_block_w/2 + i*hole_pitch;
            translate([x,0,terminal_block_d/2])
                rotate([90,0,0])
                    cylinder(h=terminal_block_h+2, r=hole_r, center=true);
        }
    }
}

// ---------- Model ----------
module pzem001(){
    // Coordinate system:
    // X: width, Y: height, Z: depth (front at z=0, back at +Z)
    union(){
        // Main body (behind bezel)
        translate([0,0,front_bezel_t])
            rounded_box(body_w, body_h, body_d, corner_r);

        // Front bezel
        difference(){
            rounded_box(front_bezel_w, front_bezel_h, front_bezel_t, corner_r+0.8);

            // Screen window recess
            translate([0, (front_bezel_h/2 - screen_margin_top - screen_h/2), 0.2])
                rounded_box(screen_w, screen_h, front_bezel_t, 1.5);

            // Button holes (3)
            by = -front_bezel_h/2 + button_offset_y;
            for(k=[-1,0,1]){
                translate([k*button_spacing, by, -0.1])
                    cylinder(h=front_bezel_t+0.4, r=button_d/2, center=false);
            }
        }

        // Screen "glass" inset
        translate([0, (front_bezel_h/2 - screen_margin_top - screen_h/2), screen_inset])
            color([0.05,0.05,0.08])
                rounded_box(screen_w-1.0, screen_h-1.0, 0.8, 1.2);

        // Buttons (3)
        by = -front_bezel_h/2 + button_offset_y;
        for(k=[-1,0,1]){
            translate([k*button_spacing, by, 0.6])
                color([0.2,0.2,0.2])
                    cylinder(h=button_h, r=button_d/2-0.3, center=false);
        }

        // Rear terminal block protrusion
        translate([0, -body_h/2 + terminal_block_h/2 + 2.0, front_bezel_t + body_d - terminal_block_offset_from_back])
            screw_terminal_block();

        // Small rear label plate (raised)
        translate([0, body_h/2 - 10, front_bezel_t + body_d - 1.2])
            color([0.15,0.15,0.15])
                rounded_box(50, 14, 1.0, 1.0);

        // Side mounting clips (simplified)
        clip_w = 10;
        clip_h = 6;
        clip_d = 3;
        clip_z = front_bezel_t + 10;
        for(side=[-1,1]){
            translate([side*(body_w/2 + clip_d/2), 0, clip_z])
                rotate([0,90,0])
                    color([0.1,0.1,0.1])
                        rounded_box(clip_d, clip_h, clip_w, 1.0);
        }
    }
}

pzem001();