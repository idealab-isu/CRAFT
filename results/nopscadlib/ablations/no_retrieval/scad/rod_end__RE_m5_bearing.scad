// uxcell M5x0.8 Right Hand Thread - Self-Lubricating Joint Rod End (Heim Joint)
// STRUCTURAL FIXES:
// - Make it a recognizable rod end: eye housing + spherical ball + integrated threaded shank
// - Ensure EVERYTHING is one connected solid (no floating parts)
// - Recalculate ALL translate() values so shank attaches to the eye with overlap
// - Keep geometry simple/clean; threads simplified

$fn = 128;

// -------------------- Parameters --------------------
overlap = 1.5;                 // 1–2mm overlap to guarantee connectivity
bridge_t = 0.55;               // tiny bridges to fuse ball to race (single solid)

thread_major_d = 5.0;          // M5 major diameter
thread_pitch   = 0.8;          // M5x0.8
thread_len     = 20.0;

shank_plain_d   = 4.6;
shank_plain_len = 2.0;

runout_relief_d   = 4.2;
runout_relief_len = 1.2;

shoulder_d   = 7.0;
shoulder_len = 2.0;

head_od        = 12.0;         // outer diameter of eye
head_thickness = 6.0;          // thickness along shank axis (X)

bore_d       = 5.0;            // bolt hole through eye (Y axis)
bore_chamfer = 0.45;

ball_d      = 8.0;             // spherical ball OD
race_wall_t = 1.6;             // housing wall around ball cavity

edge_chamfer = 0.6;

wrench_flat_width = 6.0;
wrench_flat_len   = 6.0;

dust_seal_t = 0.6;
dust_seal_r = 4.2;

// Eye shaping
eye_flat_width = 10.0;         // across flats (Y direction)
eye_flat_depth = 0.9;          // shave from OD to create flats

// Thread profile (simple printable triangular thread)
thread_depth = 0.32;           // radial depth (approx for M5)
thread_profile_w = 0.38;       // width of triangular ridge at base (2D profile)
thread_slices_per_turn = 28;   // smoothness of helix

// Derived
head_r   = head_od/2;
ball_r   = ball_d/2;
cavity_r = ball_r + race_wall_t;

// -------------------- Helpers --------------------
module cylX(r,h,center=true){ rotate([0,90,0]) cylinder(r=r,h=h,center=center); }
module cylY(r,h,center=true){ rotate([90,0,0]) cylinder(r=r,h=h,center=center); }

module end_chamfer_X(xpos, r){
    translate([xpos,0,0])
        rotate([0,90,0])
            cylinder(h=2*edge_chamfer, r1=r+edge_chamfer, r2=r, center=true);
}

module chamfer_bore_Y(sign=1){
    // conical chamfer at +/-Y face of bore
    translate([0, sign*(head_r - bore_chamfer), 0])
        rotate([90,0,0])
            cylinder(h=2*bore_chamfer, r1=bore_d/2 + bore_chamfer, r2=bore_d/2, center=true);
}

// -------------------- Head (Eye Housing) --------------------
module head_outer(){
    difference(){
        cylX(head_r, head_thickness, center=true);

        // Flats on +/-Y
        for (s=[-1,1]){
            translate([0, s*(head_r - eye_flat_depth/2), 0])
                cube([head_thickness + 2, eye_flat_depth, head_od + 2], center=true);
        }

        // Trim outside desired flat width (keeps flats from becoming too wide)
        for (s=[-1,1]){
            translate([0, s*(eye_flat_width/2 + (head_od-eye_flat_width)/2), 0])
                cube([head_thickness + 2, head_od + 2, head_od + 2], center=true);
        }

        // Edge chamfers on +/-X faces
        for (s=[-1,1]){
            translate([s*(head_thickness/2 - edge_chamfer),0,0])
                rotate([0,90,0])
                    cylinder(h=2*edge_chamfer, r1=head_r+edge_chamfer, r2=head_r, center=true);
        }
    }
}

module head_internal_cuts(){
    union(){
        // Ball cavity
        sphere(r=cavity_r);

        // Through-bore for bolt (Y axis)
        cylY(bore_d/2, head_od + 2, center=true);

        // Bore chamfers
        chamfer_bore_Y(1);
        chamfer_bore_Y(-1);
    }
}

module rod_end_head_housing(){
    difference(){
        head_outer();
        head_internal_cuts();
    }
}

// -------------------- Ball (Spherical Bearing) --------------------
module spherical_ball_with_bore_and_bridges(){
    union(){
        // Ball with through-bore
        difference(){
            sphere(r=ball_r);
            cylY(bore_d/2, ball_d + 2, center=true);
        }

        // Bridges: thin ribs connecting ball to cavity wall (single connected solid)
        // Ensure ribs actually reach into the housing by a small amount.
        rib_len = (cavity_r - ball_r) + bridge_t + 0.2;
        rib_w   = bridge_t;
        rib_h   = bridge_t;

        for (a=[0,90,180,270]){
            rotate([0,a,0])  // around Y
                translate([(ball_r + cavity_r)/2, 0, 0])
                    cube([rib_len, rib_w, rib_h], center=true);
        }
    }
}

// -------------------- Thread (Right-hand external) --------------------
module right_hand_thread_X(major_d, pitch, len, depth, profile_w){
    minor_r = major_d/2 - depth;

    union(){
        // Core cylinder at minor diameter (ensures solid shank)
        cylX(minor_r, len, center=true);

        // Helical ridge
        turns = len / pitch;
        steps = max(ceil(turns * thread_slices_per_turn), 24);

        rotate([0,90,0])  // make extrude axis align to X
            linear_extrude(height=len, twist=turns*360, slices=steps, center=true, convexity=10)
                translate([minor_r, 0, 0])
                    polygon(points=[
                        [0, -profile_w/2],
                        [depth, 0],
                        [0,  profile_w/2]
                    ]);
    }
}

// -------------------- Shank (Male Threaded, INTEGRAL) --------------------
// Build shank in LOCAL coords where x=0 is the head +X face, shank extends +X.
// Then translate so x=0 aligns to global x = +head_thickness/2 with overlap into the head.
module shank_local_solids(){
    x0 = 0;

    // Centers of each segment in LOCAL coords
    x_shoulder_c = x0 + shoulder_len/2;
    x_plain_c    = x0 + shoulder_len + shank_plain_len/2;
    x_runout_c   = x0 + shoulder_len + shank_plain_len + runout_relief_len/2;
    x_thread_c   = x0 + shoulder_len + shank_plain_len + runout_relief_len + thread_len/2;

    union(){
        translate([x_shoulder_c,0,0]) cylX(shoulder_d/2, shoulder_len, center=true);
        translate([x_plain_c,0,0])    cylX(shank_plain_d/2, shank_plain_len, center=true);
        translate([x_runout_c,0,0])   cylX(runout_relief_d/2, runout_relief_len, center=true);
        translate([x_thread_c,0,0])
            right_hand_thread_X(thread_major_d, thread_pitch, thread_len, thread_depth, thread_profile_w);
    }
}

module wrench_flats_cut_local(){
    // Flats near the start of the threaded section (LOCAL coords)
    x_thread_start = shoulder_len + shank_plain_len + runout_relief_len;
    x_flat_c = x_thread_start + wrench_flat_len/2;

    // Cut on +/-Z to create two flats
    for (s=[-1,1]){
        translate([x_flat_c, 0, s*(wrench_flat_width/2 + (thread_major_d - wrench_flat_width)/2)])
            cube([wrench_flat_len + 2, thread_major_d + 2, thread_major_d + 2], center=true);
    }
}

module shank_complete(){
    // CRITICAL CONNECTIVITY FIX:
    // Global head +X face is at +head_thickness/2.
    // Place local x=0 slightly INSIDE the head by 'overlap' so it fuses.
    shank_attach_tx = head_thickness/2 - overlap;

    translate([shank_attach_tx,0,0]){
        difference(){
            shank_local_solids();
            wrench_flats_cut_local();
        }

        // End chamfer at far end of thread (LOCAL coords)
        x_thread_end = shoulder_len + shank_plain_len + runout_relief_len + thread_len;
        x_end = x_thread_end - edge_chamfer;
        end_chamfer_X(x_end, thread_major_d/2);
    }
}

// -------------------- Dust seals (fused to head) --------------------
module dust_seals(){
    // Place seals so they overlap into the head by a small amount
    for (s=[-1,1]){
        translate([s*(head_thickness/2 - dust_seal_t/2 - overlap/2),0,0])
            rotate([0,90,0])
                rotate_extrude(convexity=10)
                    translate([dust_seal_r,0,0])
                        circle(r=dust_seal_t/2);
    }
}

// -------------------- Assembly (ONE connected solid) --------------------
module heim_joint_complete(){
    union(){
        rod_end_head_housing();                 // eye housing
        spherical_ball_with_bore_and_bridges(); // ball fused via bridges
        shank_complete();                       // integral shank (attached with overlap)
        dust_seals();                           // fused to head
    }
}

heim_joint_complete();