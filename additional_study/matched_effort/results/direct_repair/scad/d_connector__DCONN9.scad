$fn=96;

// D-sub style connector body (generic "D connector")
module d_connector(
    body_w=30,
    body_h=12,
    body_d=12,
    flange_w=38,
    flange_h=16,
    flange_t=3,
    corner_r=2,
    d_flat=0.72,          // 0..1 fraction of height where flat occurs (higher => flatter)
    shell_inset=1.2,
    shell_t=1.6,
    pin_rows=2,
    pins_per_row=5,
    pin_d=1.2,
    pin_len=6,
    pin_pitch=2.77,
    row_pitch=2.84,
    pin_offset_z=0.0,
    screw_hole_d=3.2,
    screw_boss_d=7.5,
    screw_boss_t=2.5,
    screw_spacing=30
){
    // Helper: rounded rectangle 2D
    module rrect2d(w,h,r){
        r = min(r, min(w,h)/2);
        hull(){
            translate([ w/2-r,  h/2-r]) circle(r=r);
            translate([-w/2+r,  h/2-r]) circle(r=r);
            translate([ w/2-r, -h/2+r]) circle(r=r);
            translate([-w/2+r, -h/2+r]) circle(r=r);
        }
    }

    // Helper: D-shape 2D (rounded on one side, flat on the other)
    module dshape2d(w,h,r,flat_frac){
        // flat line at y = -h/2 + h*flat_frac? Actually make flat on bottom.
        // flat_frac is fraction of height kept as curved; 0.5 gives semicircle-ish.
        // We'll create a rounded rectangle then cut with a half-plane to make a flat.
        intersection(){
            rrect2d(w,h,r);
            // Keep everything above a line to create flat bottom
            translate([0, -h/2 + h*(1-flat_frac)]) square([w*2, h*2], center=true);
        }
    }

    // Main flange with screw bosses and holes
    module flange(){
        difference(){
            linear_extrude(height=flange_t)
                rrect2d(flange_w, flange_h, corner_r);

            // Screw holes
            for(x=[-screw_spacing/2, screw_spacing/2]){
                translate([x,0,-1])
                    cylinder(d=screw_hole_d, h=flange_t+2);
            }
        }

        // Screw bosses (front side)
        for(x=[-screw_spacing/2, screw_spacing/2]){
            translate([x,0,flange_t])
                difference(){
                    cylinder(d=screw_boss_d, h=screw_boss_t);
                    translate([0,0,-1]) cylinder(d=screw_hole_d, h=screw_boss_t+2);
                }
        }
    }

    // Outer shell (D-shaped) protruding from flange
    module shell(){
        // Outer
        translate([0,0,flange_t])
            linear_extrude(height=body_d)
                dshape2d(body_w, body_h, corner_r, d_flat);

        // Inner cavity
        translate([0,0,flange_t + shell_inset])
            linear_extrude(height=max(0.01, body_d - shell_inset))
                dshape2d(body_w - 2*shell_t, body_h - 2*shell_t, max(0.1, corner_r-0.6), d_flat);
    }

    // Pins
    module pins(){
        // Place pins centered in shell
        total_w = (pins_per_row-1)*pin_pitch;
        total_h = (pin_rows-1)*row_pitch;

        // Stagger second row by half pitch (typical D-sub)
        for(r=[0:pin_rows-1]){
            y = (r - (pin_rows-1)/2)*row_pitch;
            x_shift = (r%2==1) ? pin_pitch/2 : 0;
            for(i=[0:pins_per_row-1]){
                x = (i - (pins_per_row-1)/2)*pin_pitch + x_shift;
                translate([x, y, flange_t + shell_inset + (body_d*0.35) + pin_offset_z])
                    rotate([90,0,0])
                        cylinder(d=pin_d, h=pin_len, center=false);
            }
        }
    }

    // Assemble
    difference(){
        union(){
            flange();
            // Outer shell solid
            translate([0,0,flange_t])
                linear_extrude(height=body_d)
                    dshape2d(body_w, body_h, corner_r, d_flat);
        }

        // Hollow out shell
        translate([0,0,flange_t + shell_inset])
            linear_extrude(height=max(0.01, body_d - shell_inset + 0.5))
                dshape2d(body_w - 2*shell_t, body_h - 2*shell_t, max(0.1, corner_r-0.6), d_flat);

        // Clearance behind flange for cavity opening
        translate([0,0,flange_t-0.2])
            linear_extrude(height=0.6)
                dshape2d(body_w - 2*shell_t, body_h - 2*shell_t, max(0.1, corner_r-0.6), d_flat);
    }

    // Add pins (as solid)
    color([0.85,0.75,0.2]) pins();
}

// Render
d_connector();