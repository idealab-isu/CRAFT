// Parameters
inner_bore_diameter = 6.0;
outer_diameter = 12.0;
length = 19.0;

// Linear bearing body
module linear_bearing_body() {
    cylinder(d = outer_diameter, h = length, center = true);
}

// Inner bore
module inner_bore() {
    cylinder(d = inner_bore_diameter, h = length + 2, center = true);
}

// Outer casing
module outer_casing() {
    difference() {
        linear_bearing_body();
        inner_bore();
    }
}

// Linear bearing assembly
module linear_bearing() {
    outer_casing();
}

// Render the linear bearing
linear_bearing();