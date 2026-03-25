$fn = 96;

// Parameters (mm)
shaft_diameter = 8.0;                 // requested bore
base_length = 55.0;                   // requested base X
base_width  = 42.0;                   // requested base Y
base_thickness = 8.0;

overall_height = 32.0;                // total height target (approx)
mount_hole_diameter = 6.0;
mount_hole_spacing_x = 42.0;
mount_hole_spacing_y = 28.0;

housing_material_clearance = 0.30;    // bore clearance
connection_overlap = 1.0;             // overlap to ensure watertight unions

// Pillow-block profile controls (KP08-like)
seat_outer_d = 34.0;                  // arched seat outer diameter (visual)
seat_width_y = 30.0;                  // width of arched seat (<= base_width)
arch_rise = 16.0;                     // height of arch above base top
pedestal_len = 40.0;                  // length of pedestal under arch (<= base_length)
pedestal_w   = 26.0;                  // width of pedestal under arch (<= base_width)

// Derived
bore_d = shaft_diameter + 2*housing_material_clearance;
base_top_z = base_thickness/2;
arch_center_z = base_top_z + arch_rise; // center of the arch cylinder
seat_r = seat_outer_d/2;

// Helpers
module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2-r2), sy*(w/2-r2)]) circle(r=r2);
    }
}

module base_plate(){
    // Slightly rounded base like typical cast housing
    linear_extrude(height=base_thickness, center=true)
        rounded_rect_2d(base_length, base_width, 2.0);
}

module pedestal(){
    // Pedestal block that supports the arch (connected to base with overlap)
    translate([0,0, base_top_z + (arch_rise*0.55)/2 - connection_overlap])
        linear_extrude(height=arch_rise*0.55, center=true)
            rounded_rect_2d(pedestal_len, pedestal_w, 2.0);
}

module arched_seat(){
    // Characteristic arched/raised bearing seat (half-cylinder sitting on base)
    // Use intersection to keep only the upper portion above base top.
    intersection(){
        // Full cylinder along Y (width direction)
        translate([0,0, arch_center_z])
            rotate([90,0,0])
                cylinder(r=seat_r, h=seat_width_y, center=true);

        // Keep only above base top (plus a tiny overlap)
        translate([0,0, base_top_z - connection_overlap])
            cube([base_length*2, base_width*2, overall_height*2], center=false);
    }
}

module side_gussets(){
    // Two gussets connecting pedestal to base edges (KP08-like)
    gus_h = arch_rise*0.55;
    gus_len = pedestal_len*0.55;
    gus_w = (base_width - pedestal_w)/2;
    gus_w_eff = max(2.0, gus_w);

    for (sy=[-1,1]){
        translate([0, sy*(pedestal_w/2 + gus_w_eff/2 - connection_overlap), base_top_z + gus_h/2 - connection_overlap])
            linear_extrude(height=gus_h, center=true)
                polygon(points=[
                    [-gus_len/2, -gus_w_eff/2],
                    [ gus_len/2, -gus_w_eff/2],
                    [ gus_len/2,  gus_w_eff/2],
                    [-gus_len/2,  gus_w_eff/2]
                ]);
    }
}

module mounting_holes(){
    // Through holes in base (clear, verifiable)
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_spacing_x/2, sy*mount_hole_spacing_y/2, 0])
            cylinder(d=mount_hole_diameter, h=base_thickness + 4*connection_overlap, center=true);
    }
}

module bore_and_seat(){
    // Bore through the arched seat along X (shaft axis)
    // Also add a shallow counterbore/seat recess to suggest insert bearing seat.
    bore_len = base_length + 20; // long enough to fully cut through
    seat_recess_d = 22.0;        // typical insert OD region (visual)
    seat_recess_len = 18.0;

    // Main bore
    translate([0,0, arch_center_z])
        rotate([0,90,0])
            cylinder(d=bore_d, h=bore_len, center=true);

    // Recess (centered)
    translate([0,0, arch_center_z])
        rotate([0,90,0])
            cylinder(d=seat_recess_d, h=seat_recess_len, center=true);
}

module kp08_pillow_block(){
    // ONE connected solid: union of base + pedestal + arch + gussets, then subtract holes/bores.
    difference(){
        union(){
            base_plate();
            pedestal();
            arched_seat();
            side_gussets();
        }
        mounting_holes();
        bore_and_seat();
    }
}

kp08_pillow_block();