$fn=96;

// IEC C14 filtered inlet module (approximate external model)
// Faceplate overall: 40.0 x 29.0 mm
// One connected solid; all placements derived from dimensions

// ---------- Parameters ----------
plate_w = 40.0;
plate_h = 29.0;
plate_t = 3.0;
plate_r = 2.2;

body_w = 34.0;
body_h = 23.0;
body_d = 30.0;
body_r = 1.6;

// Rear filter housing bulge
filter_w = 30.0;
filter_h = 20.0;
filter_d = 12.0;
filter_r = 1.6;

// Front bezel recess
recess_w = 32.0;
recess_h = 22.0;
recess_d = 1.6;
recess_r = 1.6;

// IEC inlet cavity (outer mouth)
inlet_w = 27.0;
inlet_h = 19.0;
inlet_d = 14.0;
inlet_r = 1.4;

// Inner connector cavity (deeper, slightly smaller) to make C14 geometry visible
inner_w = inlet_w - 3.0;
inner_h = inlet_h - 3.0;
inner_d = body_d - 6.0;
inner_r = 1.2;

// Pin openings (front) - 2 blades + earth
blade_w = 6.6;
blade_h = 2.2;
blade_depth = inlet_d + 2.0;
blade_spacing_x = 10.0;

earth_w = 4.6;
earth_h = 3.2;
earth_depth = inlet_d + 2.0;
earth_offset_y = -5.2;

// Mounting holes (4)
hole_d = 3.2;
hole_x = 16.0;
hole_y = 10.0;

// Rear terminals (spade tabs) - more recognizable than round pins
tab_w = 6.3;
tab_t = 0.8;
tab_len = 10.0;
tab_spacing_x = 10.0;
tab_spacing_y = 6.0;

// Simple fuse/switch bump on filter housing (visual cue)
fuse_w = 12.0;
fuse_h = 8.0;
fuse_d = 6.0;
fuse_r = 1.2;

// Small overlap to guarantee connectivity in unions
ov = 0.5;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d, convexity=10)
        rounded_rect_2d(w,h,r);
}

module slot_3d(w,h,d,r=0.6){
    linear_extrude(height=d, convexity=10)
        rounded_rect_2d(w,h,r);
}

// ---------- Model ----------
module iec_filtered_inlet(){
    // Z reference: front faceplate spans z=[0..plate_t], body extends negative Z
    body_z0   = -body_d;
    filter_z0 = body_z0 - filter_d + ov; // overlaps into body

    // Rear terminal placement: start at rear face of filter housing and protrude further back
    rear_face_z = filter_z0;                 // filter front face (touching body)
    tabs_z0     = rear_face_z - tab_len + ov; // tabs extend to more negative Z

    difference(){
        union(){
            // Faceplate
            rounded_box(plate_w, plate_h, plate_t, plate_r);

            // Main body behind plate (overlap into plate for watertight union)
            translate([0,0,body_z0])
                rounded_box(body_w, body_h, body_d + ov, body_r);

            // Rear filter housing bulge (overlaps into body)
            translate([0,0,filter_z0])
                rounded_box(filter_w, filter_h, filter_d, filter_r);

            // Fuse/switch-like bump on filter housing (connected)
            // Positioned on upper half of filter housing, protruding further back
            fuse_center_z = filter_z0 - fuse_d + ov; // extends behind filter
            translate([0, filter_h*0.18, fuse_center_z])
                rounded_box(fuse_w, fuse_h, fuse_d, fuse_r);

            // Rear spade terminals (solid protrusions) - 3 + earth (4 total)
            // Two line tabs
            for (sx=[-1,1]){
                translate([sx*tab_spacing_x/2, tab_spacing_y/2, tabs_z0])
                    rounded_box(tab_w, tab_t, tab_len, r=0.4);
            }
            // Neutral tab
            translate([0, -tab_spacing_y/2, tabs_z0])
                rounded_box(tab_w, tab_t, tab_len, r=0.4);

            // Earth tab (slightly lower)
            translate([0, -tab_spacing_y/2 - 2.5, tabs_z0])
                rounded_box(tab_w, tab_t, tab_len, r=0.4);
        }

        // Mounting holes through plate
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_x, sy*hole_y, -1])
                cylinder(d=hole_d, h=plate_t+2, center=false);
        }

        // Front bezel recess (inset)
        translate([0,0,plate_t - recess_d])
            rounded_box(recess_w, recess_h, recess_d + 0.2, recess_r);

        // IEC inlet cavity (main opening) - through plate into body
        translate([0,0,plate_t - inlet_d])
            rounded_box(inlet_w, inlet_h, inlet_d + 0.2, inlet_r);

        // Inner connector cavity (deeper) to make inlet recognizable in front/back views
        // Starts just behind the mouth and extends deep into the body
        inner_start_z = plate_t - inlet_d + 1.2;
        translate([0,0,inner_start_z - inner_d])
            rounded_box(inner_w, inner_h, inner_d + 0.2, inner_r);

        // Mouth relief / chamfer-like step
        translate([0,0,plate_t - 0.9])
            rounded_box(inlet_w + 1.6, inlet_h + 1.6, 1.0, inlet_r + 0.4);

        // Pin openings inside inlet cavity (front-visible)
        // Two blade slots
        for (sx=[-1,1]){
            translate([sx*blade_spacing_x/2, 2.2, plate_t - blade_depth])
                slot_3d(blade_w, blade_h, blade_depth + 0.2, r=0.6);
        }
        // Earth slot
        translate([0, earth_offset_y, plate_t - earth_depth])
            slot_3d(earth_w, earth_h, earth_depth + 0.2, r=0.6);

        // Small rear-side clearance pocket behind blades (adds depth cue)
        // Carved inside the inner cavity, not breaking outer shell
        pocket_w = inner_w - 2.0;
        pocket_h = inner_h - 2.0;
        pocket_d = 8.0;
        pocket_z = body_z0 + 6.0; // inside body, away from rear wall
        translate([0,0,pocket_z])
            rounded_box(pocket_w, pocket_h, pocket_d, r=1.0);
    }
}

iec_filtered_inlet();