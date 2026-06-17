$fn=96;

// Swiss-style spring clip (approximation)
// Units: mm

// ---------- Parameters ----------
clip_len = 70;
clip_w   = 18;
clip_t   = 2.2;

jaw_gap  = 6.0;     // opening between jaws at the tip
jaw_len  = 22;      // length of the jaw region
tip_round= 2.2;

hinge_r  = 6.5;     // outer radius of hinge loop
hinge_wall = 2.2;   // thickness of hinge loop wall
hinge_w  = clip_w;  // width of hinge loop

spring_r = 4.2;     // inner spring coil radius (visual/functional)
spring_turns = 1.25;
spring_pitch = 6.0; // along width (Z) for helix
spring_wire = 1.6;

handle_len = clip_len - jaw_len - 10;
handle_flare = 6;   // extra width at handle end
handle_round = 3;

rib_h = 0.8;
rib_pitch = 4.0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2){
    // size: [x,y,z]
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, x/2, y/2, z/2);
    minkowski(){
        cube([x-2*r2, y-2*r2, z-2*r2], center=true);
        sphere(r=r2);
    }
}

module capsule2d(len=10, r=2){
    hull(){
        translate([-len/2,0]) circle(r=r);
        translate([ len/2,0]) circle(r=r);
    }
}

module jaw_half(sign=1){
    // sign=+1 upper, -1 lower
    // Build one arm with jaw and handle, anchored at hinge center.
    arm_th = clip_t;
    arm_w  = clip_w;

    // Arm centerline along +X, thickness along Y, width along Z
    // Offset in Y to create gap at tip
    y_off = sign*(jaw_gap/2 + arm_th/2);

    translate([0, y_off, 0]){
        union(){
            // Handle (slightly flared)
            // Use hull between two rounded boxes for a gentle taper
            hull(){
                translate([hinge_r+8, 0, 0])
                    rounded_box([handle_len*0.55, arm_th, arm_w], r=handle_round);
                translate([hinge_r+8+handle_len*0.95, 0, 0])
                    rounded_box([handle_len*0.35, arm_th, arm_w+handle_flare], r=handle_round);
            }

            // Jaw region (slimmer, rounded tip)
            hull(){
                translate([hinge_r+8+handle_len*0.15, 0, 0])
                    rounded_box([jaw_len*0.55, arm_th, arm_w], r=2.2);
                translate([hinge_r+8+handle_len*0.15 + jaw_len*0.95, 0, 0])
                    rounded_box([jaw_len*0.25, arm_th, arm_w*0.92], r=tip_round);
            }

            // Small inner tooth near tip for grip
            translate([hinge_r+8+handle_len*0.15 + jaw_len*0.85, -sign*(arm_th*0.15), 0])
                rotate([0,0,0])
                    rounded_box([6, arm_th*0.9, arm_w*0.55], r=1.2);

            // Ribs on outer face for grip (handle)
            for(x=[hinge_r+12 : rib_pitch : hinge_r+12+handle_len*0.9]){
                translate([x, sign*(arm_th/2 + rib_h/2), 0])
                    rounded_box([2.2, rib_h, arm_w*0.85], r=0.6);
            }
        }
    }
}

module hinge_loop(){
    // Hinge loop centered at origin, axis along Z (width direction)
    difference(){
        rotate([90,0,0])
            cylinder(h=hinge_w, r=hinge_r, center=true);
        rotate([90,0,0])
            cylinder(h=hinge_w+0.2, r=hinge_r-hinge_wall, center=true);

        // Slot to allow arms to pass (creates a "C" loop)
        translate([hinge_r*0.15, 0, 0])
            cube([hinge_r*1.6, hinge_r*2.2, hinge_w+0.4], center=true);
    }
}

module spring_coil(){
    // Decorative/functional torsion spring approximation around hinge
    // Helix along Z, centered at origin
    // Use linear_extrude with twist on a small circle offset from axis
    turns = spring_turns;
    height = spring_pitch * turns;

    translate([0,0,-height/2])
    linear_extrude(height=height, twist=turns*360, slices=ceil(80*turns), convexity=10)
        translate([spring_r,0,0])
            circle(r=spring_wire/2);
}

module swiss_clip(){
    union(){
        // Arms
        jaw_half(+1);
        jaw_half(-1);

        // Hinge loop
        hinge_loop();

        // Spring coil inside hinge
        // Slightly offset so it doesn't intersect too much with loop walls
        scale([1,1,1])
            spring_coil();

        // Small hinge pin (visual)
        rotate([90,0,0])
            cylinder(h=hinge_w+0.6, r=1.2, center=true);
    }
}

// ---------- Render ----------
swiss_clip();