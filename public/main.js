

let perlin_image;

function preload(){
    perlin_image = loadShader('demo/vertex.glsl', 'demo/fragment.glsl');
    backgroundImage = loadImage("demo/laparoscopic-Surgery.jpg");
}
function setup(){
    createCanvas(700,700, WEBGL)
    let canvas = document.getElementById("defaultCanvas0")
    document.getElementById("canvas1").appendChild(canvas)
    shader(perlin_image);
    noStroke();
}

function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function draw(){
    let x_offset = document.getElementById("xoffset").value
    let y_offset = document.getElementById("yoffset").value
    let radius = document.getElementById("radius").value
    let animated = document.getElementById('animated').checked
    var inColor = hexToRgb(document.getElementById('inColor').value)
    let blurriness = document.getElementById('blurriness').value
    let alpha = document.getElementById('alpha').value
    let detail = document.getElementById('detail').value
    var r = inColor.r / 255
    var g = inColor.g / 255
    var b = inColor.b / 255

    clear();
    perlin_image.setUniform('detail', detail)
    perlin_image.setUniform('r',radius);
    perlin_image.setUniform('alpha', alpha)
    perlin_image.setUniform('inRed',r)
    perlin_image.setUniform('inBlue',b)
    perlin_image.setUniform('inGreen',g)
    perlin_image.setUniform('blurriness', blurriness)
    perlin_image.setUniform('x_offset',x_offset);
    perlin_image.setUniform('y_offset',y_offset);
    perlin_image.setUniform('animated',animated)
    perlin_image.setUniform('background', backgroundImage);
    perlin_image.setUniform('millis',millis());
    rect(-700/2,-700/2, 700);
}