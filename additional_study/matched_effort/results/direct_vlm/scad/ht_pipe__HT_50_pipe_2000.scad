$fn = 128;

// HT 50 pipe: OD 50 mm, wall 1.8 mm, length 2000 mm
pipe_length = 2000;
outer_d = 50;
wall = 1.8;
inner_d = outer_d - 2*wall;

eps = 0.2; // small overlap to ensure clean boolean

// Orient along X so front/back/left/right orthographic views show the pipe length
rotate([0, 90, 0])
difference() {
    cylinder(h = pipe_length, d = outer_d, center = true);
    cylinder(h = pipe_length + 2*eps, d = inner_d, center = true);
}