$fn = 96;

// =====================
// Parameters (requested)
// =====================
face_width_mm            = 56.4;   //[28.2:112.8:0.1]
body_length_mm           = 51.2;   //[25.6:102.4:0.1]
front_plate_thickness_mm = 3.0;    //[1.5:6.0:0.1]

shaft_diameter_mm        = 6.35;   //[3.175:12.7:0.01]
shaft_length_mm          = 20.0;   //[10.0:40.0:0.1]

mount_hole_spacing_mm    = 47.1;   //[23.55:94.2:0.1]
mount_hole_diameter_mm   = 4.0;    //[2.0:6.0:0.1]

hole_through_extra_mm    = 2.0;    //[1.0:6.0:0.1]
overlap_mm               = 1.0;    //[0.5:2.0:0.1]

// =====================
// Additional geometry (visual realism)
// =====================
corner_radius_mm         = 3.0;    // subtle rounding for motor body

pilot_diameter_mm        = 22.0;   // typical stepper pilot boss
pilot_height_mm          = 2.0;

rear_boss_diameter_mm    = 18.0;   // rear bearing boss
rear_boss_height_mm      = 1.5;

front_recess_diameter_mm = 38.0;   // shallow circular recess on face
front_recess_depth_mm    = 0.6;

front_ring_od_mm         = 44.0;   // raised ring around pilot
front_ring_id_mm         = 30.0;
front_ring_height_mm     = 0.8;

grill_hole_diameter_mm   = 3.0;    //[1.5:6.0:0.1]
grill_gap_mm             = 2.0;    //[1.0:6.0:0.1]

d_plug_length_mm         = 12.0;   //[6.0:24.0:0.1]   // along Z
d_plug_width_mm          = 10.0;   //[4.0:20.0:0.1]   // along Y
d_plug_thickness_mm      = 7.0;    // along X (sticks out)

// =====================
// Helpers
// =====================
module rounded_box_xy(size=[10,10,10], r=1, center=true) {
    // Rounded in XY, straight in Z
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([max(0.01, x-2*r), max(0.01, y-2*r)], center=true);
}

module mount_holes(h) {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mount_hole_spacing_mm/2, sy*mount_hole_spacing_mm/2, 0])
                cylinder(d=mount_hole_diameter_mm, h=h, center=true);
}

module grill_holes(h) {
    // 3x3 grid minus center, centered on face
    pitch = grill_hole_diameter_mm + grill_gap_mm;
    for (ix = [-1,0,1])
        for (iy = [-1,0,1])
            if (!(ix==0 && iy==0))
                translate([ix*pitch, iy*pitch, 0])
                    cylinder(d=grill_hole_diameter_mm, h=h, center=true);
}

module d_shaft(d=6.35, flat_depth=0.8, h=20) {
    // D-shaft: cylinder with one flat cut
    difference() {
        cylinder(d=d, h=h, center=true);
        r = d/2;
        // Remove a slice to create the flat; cutter positioned by formula (no arbitrary offsets)
        translate([r - flat_depth + (d*4)/2, 0, 0])
            cube([d*4, d*2.2, h+2], center=true);
    }
}

// =====================
// Assembly (ONE connected solid)
// =====================
module stepper_motor() {

    // Coordinate system:
    // Front face plate centered at Z=0, shaft goes +Z, body extends -Z.

    body_center_z  = -(front_plate_thickness_mm/2 + body_length_mm/2 - overlap_mm);
    body_back_z    = body_center_z - body_length_mm/2;

    // Connector placement (attached to +X side of body, near rear half)
    plug_center_x  = face_width_mm/2 + d_plug_thickness_mm/2 - overlap_mm;
    plug_center_z  = body_center_z - body_length_mm*0.20;

    difference() {
        union() {

            // Motor body (rounded square prism)
            translate([0,0,body_center_z])
                rounded_box_xy([face_width_mm, face_width_mm, body_length_mm], r=corner_radius_mm, center=true);

            // Front face plate (overlaps body slightly so it's clearly connected)
            translate([0,0,0])
                cube([face_width_mm, face_width_mm, front_plate_thickness_mm], center=true);

            // Raised ring detail on face (typical stepper look)
            translate([0,0, front_plate_thickness_mm/2 + front_ring_height_mm/2 - overlap_mm])
                difference() {
                    cylinder(d=front_ring_od_mm, h=front_ring_height_mm, center=true);
                    cylinder(d=front_ring_id_mm, h=front_ring_height_mm + 2*overlap_mm, center=true);
                }

            // Front pilot boss
            translate([0,0, front_plate_thickness_mm/2 + pilot_height_mm/2 - overlap_mm])
                cylinder(d=pilot_diameter_mm, h=pilot_height_mm, center=true);

            // Rear boss (bearing cap)
            translate([0,0, body_back_z - rear_boss_height_mm/2 + overlap_mm])
                cylinder(d=rear_boss_diameter_mm, h=rear_boss_height_mm, center=true);

            // Shaft (D-shaft), protruding from FRONT (+Z)
            translate([0,0, front_plate_thickness_mm/2 + shaft_length_mm/2 - overlap_mm])
                d_shaft(d=shaft_diameter_mm, flat_depth=0.8, h=shaft_length_mm);

            // Connector block on side of body (connected)
            translate([plug_center_x, 0, plug_center_z])
                cube([d_plug_thickness_mm, d_plug_width_mm, d_plug_length_mm], center=true);
        }

        // =====================
        // Subtractions (holes/details)
        // =====================

        // Mounting holes through face plate
        mount_holes(front_plate_thickness_mm + hole_through_extra_mm);

        // Shallow circular recess on face plate (adds typical face detail)
        translate([0,0, front_plate_thickness_mm/2 - front_recess_depth_mm/2])
            cylinder(d=front_recess_diameter_mm, h=front_recess_depth_mm + overlap_mm, center=true);

        // Center grill holes on face plate (visual detail)
        grill_holes(front_plate_thickness_mm + hole_through_extra_mm);

        // Center shaft clearance hole through face plate (visual/typical)
        cylinder(d=shaft_diameter_mm + 1.0, h=front_plate_thickness_mm + hole_through_extra_mm, center=true);
    }
}

stepper_motor();