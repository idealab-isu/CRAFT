$fn = 64;

// Parameters
rail_length = 100.0; //[50.0:200.0:1.0]
rail_width  = 7.0;   //[3.5:14.0:0.1]
rail_height = 5.0;   //[2.5:10.0:0.1]

// Detail parameters (kept proportional; clamped to stay valid at small sizes)
edge_chamfer = min(0.6, rail_width*0.12, rail_height*0.18);
top_land_w   = max(rail_width*0.35, rail_width - 2*(rail_width*0.28)); // central top flat
top_land_w   = min(top_land_w, rail_width - 2*edge_chamfer);

race_r       = min(0.9, rail_height*0.22, rail_width*0.18);
race_depth   = min(0.55, rail_height*0.18);
race_y_off   = rail_width/2 - edge_chamfer - race_r*0.9;

hole_d       = min(3.0, rail_width*0.45);
hole_r       = hole_d/2;
csk_d        = min(4.6, rail_width*0.70);
csk_r        = csk_d/2;
csk_h        = min(1.2, rail_height*0.28);

end_margin   = max(8, rail_width*1.2);
hole_pitch   = 25;
hole_count   = max(2, floor((rail_length - 2*end_margin)/hole_pitch) + 1);
hole_span    = (hole_count-1)*hole_pitch;
first_hole_x = -hole_span/2;

// 2D profile (X=width, Y=height) extruded along Z=length
module rail_profile_2d() {
    w = rail_width;
    h = rail_height;
    c = edge_chamfer;
    tl = top_land_w;

    // Symmetric trapezoid-ish profile with small chamfers
    // Bottom is full width; top is narrower (tl), with chamfered shoulders.
    polygon(points=[
        [-w/2, 0],
        [ w/2, 0],
        [ w/2, h - c],
        [ tl/2 + c, h],
        [-tl/2 - c, h],
        [-w/2, h - c]
    ]);
}

module rail_body() {
    color("Silver")
    difference() {
        // Main solid
        linear_extrude(height=rail_length, center=true, convexity=10)
            rail_profile_2d();

        // Raceway grooves (subtractive), running full length
        for (side = [-1, 1]) {
            translate([side*race_y_off, rail_height*0.55, 0])
                rotate([90, 0, 0])  // cylinder axis along Y; after rotate, along Z (extrude direction)
                    cylinder(r=race_r, h=rail_length + 0.2, center=true);
            // Slightly flatten the groove to look like a raceway
            translate([side*race_y_off, rail_height*0.55 - race_depth, 0])
                cube([2*race_r*1.6, race_depth*2, rail_length + 0.2], center=true);
        }

        // Mounting holes with shallow countersink from the top
        for (i = [0:hole_count-1]) {
            x = first_hole_x + i*hole_pitch;

            // Through hole (along height)
            translate([0, rail_height/2, x])
                rotate([90, 0, 0])
                    cylinder(r=hole_r, h=rail_height + 0.4, center=true);

            // Countersink (from top surface down)
            translate([0, rail_height - csk_h/2, x])
                rotate([90, 0, 0])
                    cylinder(r1=csk_r, r2=hole_r, h=csk_h + 0.2, center=true);
        }
    }
}

// Final Output (one connected solid)
rail_body();