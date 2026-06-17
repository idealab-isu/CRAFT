// Dome head screw: 5.0mm shank dia, 9.5mm head dia, 2.75mm head height, 10mm length under head
// One connected solid, with visible helical thread and a simple hex socket drive.

$fn = 96;

// Parameters
shank_diameter        = 5.0;   //[2.5:10.0:0.1]
length_under_head     = 10.0;  //[5.0:30.0:0.1]
head_diameter         = 9.5;   //[4.75:19.0:0.1]
head_height           = 2.75;  //[1.4:6.0:0.05]

tip_chamfer_length    = 0.8;   //[0.4:2.0:0.05]
thread_pitch          = 0.8;   //[0.4:2.0:0.05]
thread_length         = 9.0;   //[4.5:25.0:0.1]
thread_depth          = 0.25;  //[0.1:0.6:0.05]
runout_length         = 1.0;   //[0.5:3.0:0.1]

underhead_fillet_radius = 0.6; //[0.3:1.5:0.05]
drive_hex_flat         = 4.0;  //[2.0:6.0:0.1]   // across flats
drive_recess_depth     = 1.6;  //[0.8:4.0:0.1]

overlap               = 0.15;  //[0.05:0.5:0.05]

// Derived
shank_r = shank_diameter/2;
head_r  = head_diameter/2;

// Spherical cap radius for dome head (cap height = head_height, base radius = head_r)
dome_radius = (head_r*head_r + head_height*head_height) / (2*head_height);

// Coordinate convention:
// z=0 at underside of head (bearing surface).
// Shank extends to negative z. Head extends to positive z.

module dome_head() {
    // Spherical cap intersected with a cylinder to enforce head diameter
    intersection() {
        translate([0,0, head_height - dome_radius])
            sphere(r=dome_radius);
        // limit to head diameter and height
        translate([0,0, head_height/2])
            cylinder(h=head_height + 2*overlap, r=head_r, center=true);
    }
}

module underhead_fillet() {
    // Small torus-like fillet blending shank into head underside
    // Positioned so it overlaps both head underside (z=0) and shank (z<0)
    translate([0,0, 0])
        rotate_extrude($fn=128)
            translate([shank_r + underhead_fillet_radius, 0, 0])
                circle(r=underhead_fillet_radius, $fn=64);
}

module shank_core() {
    // Core cylinder (minor diameter) for threads to sit on
    // Use minor radius = shank_r - thread_depth (clamped)
    minor_r = max(0.01, shank_r - thread_depth);
    translate([0,0, -length_under_head/2])
        cylinder(h=length_under_head + overlap, r=minor_r, center=true);
}

module thread_helix() {
    // Simple triangular thread ridge via linear_extrude with twist
    // Ridge is placed at minor radius and extends outward by thread_depth.
    minor_r = max(0.01, shank_r - thread_depth);
    turns = thread_length / thread_pitch;

    // 2D profile in XY plane: a small triangle whose inner edge is at minor_r
    // and outer tip reaches shank_r (major radius).
    // Height in Y is small to avoid self-intersection.
    tri_w = thread_pitch * 0.55; // along Y
    polygon_pts = [
        [minor_r, -tri_w/2],
        [minor_r,  tri_w/2],
        [minor_r + thread_depth, 0]
    ];

    translate([0,0, -thread_length + overlap])  // start near tip end
        linear_extrude(height=thread_length + 2*overlap, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
            polygon(points=polygon_pts);
}

module thread_runout() {
    // Taper the last runout_length near the head to blend threads into shank
    // Implemented as a conical sleeve added on top of the thread helix region.
    minor_r = max(0.01, shank_r - thread_depth);
    z0 = -runout_length; // from z=-runout_length up to z=0
    translate([0,0, z0/2])
        cylinder(h=runout_length + 2*overlap, r1=shank_r, r2=minor_r, center=true);
}

module tip_chamfer() {
    // Conical tip at the end of the shank (z = -length_under_head)
    translate([0,0, -length_under_head + tip_chamfer_length/2])
        cylinder(h=tip_chamfer_length + 2*overlap, r1=shank_r, r2=0.01, center=true);
}

module drive_recess_hex() {
    // Hex socket recess cut into the dome head
    // Place it so its top is slightly below the dome top.
    // Recess spans from z = head_height - drive_recess_depth downwards.
    z_center = head_height - drive_recess_depth/2;
    translate([0,0, z_center])
        cylinder(h=drive_recess_depth + 2*overlap, r=drive_hex_flat/(2*cos(180/6)), $fn=6, center=true);
}

module screw_solid() {
    union() {
        // Head (dome) + fillet
        dome_head();
        underhead_fillet();

        // Shank core (minor diameter) + thread ridge + runout + tip
        shank_core();
        thread_helix();
        thread_runout();
        tip_chamfer();
    }
}

difference() {
    color("DimGray") screw_solid();
    drive_recess_hex();
}