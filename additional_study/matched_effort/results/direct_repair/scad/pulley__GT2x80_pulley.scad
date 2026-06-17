$fn=180;

// Timing pulley parameters
teeth = 80;
pitch_d = 50.42;          // mm (given)
pitch = PI * pitch_d / teeth;  // circular pitch derived from pitch diameter & tooth count

// Simple, renderable pulley geometry (approximate tooth form)
// Note: This is a generic toothed pulley approximation, not a specific belt standard profile.
pulley_width = 16;        // mm
hub_d = 28;               // mm (bore/hub region diameter)
bore_d = 5;               // mm
flange_th = 1.5;          // mm
flange_over = 3;          // mm radial over tooth OD

// Tooth geometry (approx)
tooth_height = 1.6;       // mm radial height above pitch radius
tooth_tip_width = pitch * 0.45;   // mm (arc chord approx at pitch radius)
tooth_root_width = pitch * 0.75;  // mm
tooth_fillet = 0.4;       // mm (2D rounding)

// Derived radii
pitch_r = pitch_d/2;
tooth_tip_r = pitch_r + tooth_height;
tooth_root_r = pitch_r - 0.8;     // small dedendum
body_r = max(hub_d/2, tooth_root_r);
tooth_od = 2*tooth_tip_r;
flange_d = tooth_od + 2*flange_over;

module rounded_trapezoid_2d(w_top, w_bot, h, r=0.3){
    // Centered on X, base at y=0, top at y=h
    // Rounded via offset trick
    offset(r=r) offset(delta=-r)
        polygon(points=[
            [-w_bot/2, 0],
            [ w_bot/2, 0],
            [ w_top/2, h],
            [-w_top/2, h]
        ]);
}

module tooth_3d(){
    // Tooth centered at origin, extends outward in +Y direction from root radius
    // We'll place it at pitch radius and rotate around Z.
    linear_extrude(height=pulley_width, center=true, convexity=10)
        translate([0, tooth_root_r])
            rounded_trapezoid_2d(
                w_top=tooth_tip_width,
                w_bot=tooth_root_width,
                h=(tooth_tip_r - tooth_root_r),
                r=tooth_fillet
            );
}

module pulley_body(){
    difference(){
        union(){
            // Main cylinder up to tooth root
            cylinder(h=pulley_width, r=body_r, center=true);

            // Teeth
            for(i=[0:teeth-1]){
                rotate([0,0, i*360/teeth])
                    tooth_3d();
            }

            // Flanges
            translate([0,0, (pulley_width/2 + flange_th/2)])
                cylinder(h=flange_th, r=flange_d/2, center=true);
            translate([0,0, -(pulley_width/2 + flange_th/2)])
                cylinder(h=flange_th, r=flange_d/2, center=true);
        }

        // Bore
        cylinder(h=pulley_width + 2*flange_th + 2, r=bore_d/2, center=true);
    }
}

pulley_body();