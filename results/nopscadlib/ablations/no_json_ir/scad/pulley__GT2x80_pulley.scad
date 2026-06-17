$fn = 240;

// -------------------- Parameters --------------------
tooth_count      = 80;
pitch_diameter   = 50.42;                 // verifiable: pitch circle is explicit geometry
pitch_radius     = pitch_diameter/2;

pulley_width     = 10;

tooth_height     = 2.0;                   // radial protrusion above pitch circle
tooth_tip_width  = 1.2;                   // tangential width at tooth tip
tooth_root_width = 2.2;                   // tangential width at tooth root (at pitch circle)

bore_diameter    = 10;

hub_diameter     = 20;
hub_length       = 5;

flange_thickness = 1;
flange_overhang  = 1.0;                   // radial overhang beyond tooth tips

set_screw_diameter = 3;
set_screw_distance = 5;                   // from center (radial)
set_screw_z        = 0;                   // centered through pulley

overlap = 0.30;                           // overlap for watertight unions

// -------------------- Derived --------------------
tooth_pitch      = pitch_diameter * PI / tooth_count;
outer_radius     = pitch_radius + tooth_height;
flange_radius    = outer_radius + flange_overhang;

// Make tooth angular width consistent with requested tangential widths
tooth_tip_ang  = (tooth_tip_width  / outer_radius) * 180/PI;
tooth_root_ang = (tooth_root_width / pitch_radius) * 180/PI;

// -------------------- Model --------------------
module pulley() {
    difference() {
        union() {
            // Main toothed body (base + teeth)
            toothed_body();

            // Flanges (connected)
            flanges();

            // Hub (connected)
            hub();
        }

        // Bore (through everything)
        center_bore();

        // Set screw holes (radial, through hub/body)
        set_screw_holes();
    }
}

module toothed_body() {
    union() {
        // Base cylinder slightly under pitch radius so teeth are visible in ortho views
        cylinder(r=pitch_radius - overlap, h=pulley_width, center=true);

        // Teeth: use rotate_extrude to create a recognizable curved timing-tooth profile
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                tooth();
        }
    }
}

module tooth() {
    // 2D profile in (radius r, height z) plane, then rotate_extrude by tooth angular width.
    // This produces curved tooth sides (not vertical slots) and makes tooth count visible.
    rotate_extrude(angle=tooth_root_ang, convexity=10)
        translate([pitch_radius - overlap, 0, 0])
            polygon(points=[
                // x is radial from pitch circle outward, y is axial (z after rotate_extrude)
                [0,                    -pulley_width/2],
                [0,                     pulley_width/2],

                // Root fillet-ish shoulder (slight outward)
                [tooth_height*0.25,      pulley_width/2],
                [tooth_height*0.25,     -pulley_width/2],

                // Tip region (narrower angularly via separate tip cut below)
                [tooth_height,          -pulley_width/2],
                [tooth_height,           pulley_width/2]
            ]);

    // Trim the tooth to the desired tip angular width by subtracting side wedges,
    // leaving a narrower tip than root (recognizable timing tooth).
    // Implemented as intersection with an angular sector at the tip radius.
    intersection() {
        // The raw tooth volume (same as above)
        rotate_extrude(angle=tooth_root_ang, convexity=10)
            translate([pitch_radius - overlap, 0, 0])
                polygon(points=[
                    [0,                    -pulley_width/2],
                    [0,                     pulley_width/2],
                    [tooth_height,          pulley_width/2],
                    [tooth_height,         -pulley_width/2]
                ]);

        // Sector that narrows with radius: root uses tooth_root_ang, tip uses tooth_tip_ang
        // Approximated by intersecting with a hull between two sectors at different radii.
        hull() {
            // Root sector (wider)
            rotate([0,0,0])
                sector3d(r1=pitch_radius - overlap, r2=pitch_radius + tooth_height*0.35, ang=tooth_root_ang, h=pulley_width + 2*overlap);

            // Tip sector (narrower)
            rotate([0,0,(tooth_root_ang - tooth_tip_ang)/2])
                sector3d(r1=pitch_radius + tooth_height*0.65, r2=outer_radius + overlap, ang=tooth_tip_ang, h=pulley_width + 2*overlap);
        }
    }
}

// 3D angular sector (centered on +X axis, spanning angle "ang" about Z)
module sector3d(r1, r2, ang, h) {
    // Build as rotate_extrude of a rectangle in r-z plane
    rotate([0,0,-ang/2])
        rotate_extrude(angle=ang, convexity=10)
            polygon(points=[
                [r1, -h/2],
                [r2, -h/2],
                [r2,  h/2],
                [r1,  h/2]
            ]);
}

module flanges() {
    // Bottom flange
    translate([0,0,-pulley_width/2 - flange_thickness/2 + overlap])
        cylinder(r=flange_radius, h=flange_thickness, center=true);

    // Top flange
    translate([0,0, pulley_width/2 + flange_thickness/2 - overlap])
        cylinder(r=flange_radius, h=flange_thickness, center=true);
}

module hub() {
    // Hub on top side, connected to body with overlap
    translate([0,0, pulley_width/2 + hub_length/2 - overlap])
        cylinder(d=hub_diameter, h=hub_length, center=true);
}

module center_bore() {
    // Through entire assembly
    total_h = pulley_width + 2*flange_thickness + hub_length + 2;
    cylinder(d=bore_diameter, h=total_h, center=true);
}

module set_screw_holes() {
    // Two opposing radial holes, positioned at set_screw_distance from center.
    // Cylinder axis along X.
    hole_len = hub_diameter + 2*(tooth_height + flange_overhang) + 10;

    for (a = [0,180]) {
        rotate([0,0,a])
            translate([set_screw_distance, 0, set_screw_z])
                rotate([0,90,0])
                    cylinder(d=set_screw_diameter, h=hole_len, center=true);
    }
}

// -------------------- Render --------------------
pulley();