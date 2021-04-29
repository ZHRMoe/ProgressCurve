//
//  ContentView.swift
//  ProgressCurve
//
//  Created by ZHRMoe on 2021/4/29.
//

import SwiftUI
import CoreGraphics

struct ShapeToClip: Shape {
    
    var circleCenter: CGPoint = .zero
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect.init(x: -5, y: -5, width: rect.width + 10, height: rect.width + 10))
        path.addPath(CircleToClip(circleCenter: circleCenter).path(in: rect))
        return path
    }
    
}

struct CircleToClip: Shape {

    var circleCenter: CGPoint = .zero
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect.init(origin: CGPoint.init(x: circleCenter.x - 10, y: circleCenter.y - 10), size: CGSize.init(width: 20, height: 20)))
        return path
    }
    
}

struct CenterLine: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint.init(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint.init(x: rect.maxX, y: rect.midY))
        return path
    }
    
}

struct Curve: Shape {
    
    var progress: CGFloat = 1
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint.init(x: rect.minX, y: rect.maxY))
        path.addCurve(to: CGPoint.init(x: rect.midX, y: rect.minY), control1: CGPoint.init(x: rect.minX + rect.width / 5, y: rect.maxY), control2: CGPoint.init(x: rect.midX - rect.width / 5, y: rect.minY))
        path.addCurve(to: CGPoint.init(x: rect.maxX, y: rect.maxY), control1: CGPoint.init(x: rect.midX + rect.width / 5, y: rect.minY), control2: CGPoint.init(x: rect.maxX - rect.width / 5, y: rect.maxY))
        return path.trimmedPath(from: 0, to: progress)
    }
    
}

struct ContentView: View {
    
    var progress: CGFloat = 0.35
    
    func getPositon(rect: CGRect) -> CGPoint {
        let lp0 = CGPoint.init(x: rect.minX, y: rect.maxY)
        let lp1 = CGPoint.init(x: rect.minX + rect.width / 5, y: rect.maxY)
        let lp2 = CGPoint.init(x: rect.midX - rect.width / 5, y: rect.minY)
        let lp3 = CGPoint.init(x: rect.midX, y: rect.minY)
        
        let rp0 = CGPoint.init(x: rect.midX, y: rect.minY)
        let rp1 = CGPoint.init(x: rect.midX + rect.width / 5, y: rect.minY)
        let rp2 = CGPoint.init(x: rect.maxX - rect.width / 5, y: rect.maxY)
        let rp3 = CGPoint.init(x: rect.maxX, y: rect.maxY)
        
        if progress < 0.5 {
            let t = progress * 2.0
            let x = lp0.x * pow((1 - t), 3) + 3 * lp1.x * t * pow((1 - t), 2) + 3 * lp2.x * pow(t, 2) * (1 - t) + lp3.x * pow(t, 3)
            let y = lp0.y * pow((1 - t), 3) + 3 * lp1.y * t * pow((1 - t), 2) + 3 * lp2.y * pow(t, 2) * (1 - t) + lp3.y * pow(t, 3)
            return CGPoint(x: x, y: y)
        } else if progress > 0.5 {
            let t = (progress - 0.5) * 2
            let x = rp0.x * pow((1 - t), 3) + 3 * rp1.x * t * pow((1 - t), 2) + 3 * rp2.x * pow(t, 2) * (1 - t) + rp3.x * pow(t, 3)
            let y = rp0.y * pow((1 - t), 3) + 3 * rp1.y * t * pow((1 - t), 2) + 3 * rp2.y * pow(t, 2) * (1 - t) + rp3.y * pow(t, 3)
            return CGPoint(x: x, y: y)
        } else if progress == 0.5 {
            return CGPoint(x: rect.midX, y: rect.minY)
        }
        return .zero
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            CenterLine()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .square))
            ZStack {
                GeometryReader { geo in
                    let rect = geo.frame(in: CoordinateSpace.named("curveStack"))
                    let point = getPositon(rect: rect)
                    Curve()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .square))
                        .clipShape(ShapeToClip(circleCenter: point), style: FillStyle.init(eoFill: true, antialiased: true))
                    Curve(progress: progress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .square))
                        .clipShape(ShapeToClip(circleCenter: point), style: FillStyle.init(eoFill: true, antialiased: true))
                    Circle()
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .square))
                        .frame(width: 20, height: 20)
                        .position(x: point.x, y: point.y)
                }
            }
            .frame(height: 75)
            .coordinateSpace(name: "curveStack")
        }
        .frame(width: 155, height: 155, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
