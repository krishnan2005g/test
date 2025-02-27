import SwiftUI

struct TransactionSuccessView: View {
    @Binding var isPresented: Bool
    @State private var checkmarkProgress: CGFloat = 0
    @State private var haloScale: CGFloat = 0
    @State private var haloOpacity: Double = 1
    @State private var showContent = false
    @State private var particles: [Particle] = []
    
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
                            // Animated checkmark
                            CheckmarkShape()
                                .trim(from: 0, to: checkmarkProgress)
                                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .foregroundColor(.green)
                                .frame(width: 100, height: 100)
                                .shadow(color: .green.opacity(0.4), radius: 10)
                            
                            // Pulsing halo
                            Circle()
                                .strokeBorder(Color.green.opacity(0.3), lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .scaleEffect(haloScale)
                                .opacity(haloOpacity)
                        }
                        
                        // Text content
                        VStack(spacing: 8) {
                            Text("Payment Successful")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                            
                            Text("Your transaction has been completed.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                        
                        // Action button
                        GradientButton(title: "OK") {
                            dismiss()
                        }
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
                    
                    // Confetti particles
                    ForEach(particles) { particle in
                        ParticleView(particle: particle)
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
        withAnimation(.easeInOut(duration: 0.5)) {
            checkmarkProgress = 1
        }
        
        withAnimation(.easeInOut(duration: 1).delay(0.2)) {
            haloScale = 2
            haloOpacity = 0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            showContent = true
        }
        
        generateParticles()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func generateParticles() {
        let colors: [Color] = [.green, .yellow, .blue, .pink, .purple]
        for _ in 0..<50 {
            let particle = Particle(
                color: colors.randomElement()!,
                x: CGFloat.random(in: -1...1),
                y: CGFloat.random(in: -1...1),
                scale: CGFloat.random(in: 0.5...1.5),
                speed: CGFloat.random(in: 0.5...2)
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
        checkmarkProgress = 0
        haloScale = 0
        haloOpacity = 1
        showContent = false
        particles = []
    }
}

// MARK: - Custom Shapes and Components

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.25))
        return Path(path.cgPath)
    }
}

struct GradientButton: View {
    let title: String
    let action: () -> Void
    @State private var pressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.primaryTheme, Color.primaryTheme.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(15)
                )
                .scaleEffect(pressed ? 0.95 : 1)
                .animation(.easeInOut(duration: 0.2), value: pressed)
        }
        .buttonStyle(ScaleButtonStyle(pressed: $pressed))
    }
}

struct ScaleButtonStyle: ButtonStyle {
    @Binding var pressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                pressed = newValue
                if newValue {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

// MARK: - Particle Effects

struct Particle: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
    let speed: Double
}

struct ParticleView: View {
    let particle: Particle
    @State private var isActive = false
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 8, height: 8)
            .scaleEffect(isActive ? 0.1 : particle.scale)
            .offset(x: isActive ? particle.x * 200 : 0,
                    y: isActive ? particle.y * 200 : 0)
            .opacity(isActive ? 0 : 1)
            .rotation3DEffect(
                .degrees(isActive ? 360 : 0),
                axis: (x: particle.x, y: particle.y, z: 0)
            )
            .onAppear {
                withAnimation(.easeOut(duration: particle.speed)) {
                    isActive = true
                }
            }
    }
}
