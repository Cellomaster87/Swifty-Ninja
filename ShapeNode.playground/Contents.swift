import SpriteKit
import UIKit

// Getting started with SKShapeNode
let path = CGMutablePath()
path.addArc(center: .zero, radius: 15, startAngle: 0, endAngle: .pi * 2, clockwise: true)

let ball = SKShapeNode(path: path)
ball.lineWidth = 1
ball.fillColor = .blue
ball.strokeColor = .white
ball.glowWidth = 0.5

// Creating a Shape Node from an Array of Points
var points = [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100), CGPoint(x: 200, y: -50), CGPoint(x: 300, y: 30), CGPoint(x: 400, y: 20)]
let linearShapeNode = SKShapeNode(points: &points, count: points.count)
linearShapeNode.strokeColor = .blue
let splineShapeNode = SKShapeNode(splinePoints: &points, count: points.count)
splineShapeNode.strokeColor = .red

linearShapeNode
splineShapeNode

// Controlling Shape Drawing with Shaders
// Customize a Shape Node's Stroke
let gradientShader = SKShader(source: "void main() {" +
    "float normalisedPosition = v_path_distance / u_path_length;" +
    "gl_FragColor = vec4(normalisedPosition, normalisedPosition, 0.0, 1.0);" +
    "}")
let squareShapeNode = SKShapeNode(rectOf: CGSize(width: 610, height: 200), cornerRadius: 25)
squareShapeNode.fillColor = .clear
squareShapeNode.lineWidth = 20
squareShapeNode.strokeShader = gradientShader
squareShapeNode

let dashedShader = SKShader(source: "void main() {" +
    "int stripe = int(u_path_length) / 150;" +
    "int h = int(v_path_distance) / stripe % 2;" +
    "gl_FragColor = float4(h);" +
    "}")

squareShapeNode.strokeShader = dashedShader
squareShapeNode // this doesn't work like in the example

// Customize a Shape Node's Fill
let checkerboardShader = SKShader(source: "void main() {" +
    "int size = 20;" +
    "int h = int(v_tex_coord.x * u_texture_size.x) / size % 2;" +
    "int v = int(v_tex_coord.y * u_texture_size.y) / size % 2;" +
    "gl_FragColor = float4(v ^ h, v ^ h, v ^ h, 1.0);" +
    "}")

let size = CGSize(width: 610, height: 200)

checkerboardShader.uniforms = [
    SKUniform(name: "u_texture_size", vectorFloat2: vector_float2(Float(size.width), Float(size.height)))
]

let squareShapeNode2 = SKShapeNode(rectOf: size, cornerRadius: 25)
squareShapeNode2.fillShader = checkerboardShader
// some piece of code is missing from the example because these last two excerpts do not provide the desired result.
