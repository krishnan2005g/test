//
//  TransactionErrorView.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-26.
//


import SwiftUI

struct TransactionErrorView: View {
    @Binding var isPresented: Bool
    @State private var pathProgress: CGFloat = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var showContent = false
    @State private var particles: [Particle] = []
    @State private var glowIntensity: CGFloat = 0
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(0)
                
                // Main content
                ZStack {
                    VStack(spacing: 20) {
                        ZStack {
                            // Error icon container
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                                )
                                .shadow(color: .red.opacity(glowIntensity), radius: 20)
                            
                            // Animated X mark
                            XMarkShape()
                                .trim(from: 0, to: pathProgress)
                                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .foregroundColor(.red)
                                .frame(width: 60, height: 60)
                                .offset(x: shakeOffset)
                        }
                        
                        // Text content
                        VStack(spacing: 8) {
                            Text("Payment Failed")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            Text("Transaction could not be completed.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                        
                        // Action button
                        GradientButton(title: "Try Again", action: {
                            dismiss()
                        })
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    )
                    .padding(20)
                    .scaleEffect(showContent ? 1 : 0.8)
                    
                    // Error particles
                    ForEach(particles) { particle in
                        ErrorParticleView(particle: particle)
                    }
                }
                .zIndex(1)
                .onAppear(perform: animateAll)
                .onDisappear(perform: reset)
            }
        }
        .animation(.default, value: isPresented)
    }
    
    private func animateAll() {
        // X mark drawing animation
        withAnimation(.easeInOut(duration: 0.4)) {
            pathProgress = 1
        }
        
        // Shake effect
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
            shakeOffset = -20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                shakeOffset = 20
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                shakeOffset = 0
            }
        }
        
        // Pulsing glow
        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            glowIntensity = 0.5
        }
        
        // Content entrance
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            showContent = true
        }
        
        generateParticles()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    private func generateParticles() {
        let colors: [Color] = [.red, .orange, .yellow]
        for _ in 0..<30 {
            let particle = Particle(
                color: colors.randomElement()!,
                x: CGFloat.random(in: -1...1),
                y: CGFloat.random(in: -1...1),
                scale: CGFloat.random(in: 0.5...1.5),
                speed: CGFloat.random(in: 0.5...1)
            )
            particles.append(particle)
        }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
        }
    }
    
    private func reset() {
        pathProgress = 0
        shakeOffset = 0
        showContent = false
        particles = []
        glowIntensity = 0
    }
}

// MARK: - Custom Components

struct XMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }
}

struct ErrorParticleView: View {
    let particle: Particle
    @State private var isActive = false
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 6, height: 6)
            .scaleEffect(isActive ? 0.1 : particle.scale)
            .offset(
                x: isActive ? particle.x * 150 : 0,
                y: isActive ? particle.y * 150 : 0
            )
            .opacity(isActive ? 0 : 1)
            .blur(radius: isActive ? 4 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: particle.speed)) {
                    isActive = true
                }
            }
    }
}
