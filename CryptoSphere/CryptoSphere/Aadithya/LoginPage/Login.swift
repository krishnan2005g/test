//
//  Login.swift
//  CS_LoginPage
//
//  Created by Aadithya K S on 16/02/25.
//

import SwiftUI
import GoogleSignIn
import SwiftData

// MARK: Assigned constants for screen size in Global Scope
let height = UIScreen.main.bounds.height
let width = UIScreen.main.bounds.width
var slideSheet = false

struct Login: View {
    
    @Query private var sessions: [UserSession]
    @Environment(\.globalViewModel) private var globalViewModel
    @State var currentSession: UserSession = UserSession()
    @Namespace var profileAnimation
    
    var body: some View {
        if !currentSession.isSignedIn {
            LoginBackgroundView(session: $currentSession)
                .onAppear { restoreSession() }
        } else {
            UsersListView(profileAnimation: profileAnimation, onSelectUser: { user, _ in
                withAnimation{
                    AnyView(ChatView(toUser: user, profileAnimation: profileAnimation))
                }
            })
            .onAppear {
                Task{
                    await ServerResponce.shared.addUser(user: globalViewModel.session)
                    await WebSocketManager.shared.connect()
                }
            }
        }
    }
    
    private func restoreSession() {
        if sessions.isEmpty {
            return
        }
        currentSession = sessions.last!
        UserSession.shared = currentSession
        globalViewModel.session = User(email: currentSession.emailAddress ?? "", username: currentSession.userName ?? "", password: "Google Sign In", profilePicture: currentSession.profileImageURL ?? "")
    }
    
}

struct OnboardView: View{
    
    let imageName : String
    let title : String
    let description : String
    
    var body : some View{
        VStack(spacing: 20){
            Image(systemName: imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.primaryTheme)
            
            Text(title)
                .font(.custom("ZohoPuvi-ExtraBold", size: 28))
            
            Text(description)
                .font(.custom("Rockwell", size: 18))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 40)
    }
}


struct LoginBackgroundView: View {
    
    @State private var currentOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var visibleCount = 0
    @State private var scale = 0.0
    @State private var secScale = 0.0
    @State private var slideInitial = 140.0
    @State private var infoOffset = 60.0
    
    @Binding var session: UserSession
    @Environment(\.globalViewModel) private var globalViewModel
    @Environment(\.modelContext) private var modelContext
    
    let sentences = [
        "You're only a few steps away",
        "from CryptoSphere"
    ]
    
    var body: some View{
        ZStack {
            IntroPlayerWrapper()
                .ignoresSafeArea()
                .blur(radius: getBlurRadius())
            
            ZStack {
                Color(.grayButton)
                    .frame(width: width, height: height)
                    .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                    .padding(.top, 100)
                
                VStack {
                    Capsule()
                        .fill(.primaryTheme)
                        .frame(width: 70, height: 12)
                        .padding(.top, 120)
                    
                    VStack(spacing: 10) {
                        ForEach(sentences.indices, id: \.self) { index in
                            Text(sentences[index])
                                .font(.custom("ZohoPuvi-Bold", size: 22))
                                .foregroundStyle(.white)
                                .opacity(visibleCount > index ? 1 : 0)
                        }
                    }
                    .padding(.top, 40)
                    
                    Button(action: {
                        slideSheet = true
                        showSheet()
                    }) {
                        Text("Get Started")
                            .font(.custom("ZohoPuvi-Bold", size: 22))
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                    }
                    .background(.primaryTheme)
                    .clipShape(RoundedRectangle(cornerRadius: 65))
                    .offset(y: 40)
                    .scaleEffect(scale)
                    
                    VStack{
                        Page()
                            .offset(y : infoOffset)
                        
                        Button(action: {}) {
                            HStack(spacing: 15){
                                Image("GoogleIcon")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                
                                Text("Sign in with Google")
                                    .font(.custom("ZohoPuvi-ExtraBold", size: 20))
                                    .foregroundColor(.grayButton)
                                    .onTapGesture {
                                        let targetSession = UserSession(isSignedIn: false)
                                        modelContext.insert(targetSession)
                                        
                                        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
                                            guard let user = result?.user, error == nil else {
                                                print("Sign in error: \(String(describing: error))")
                                                return
                                            }
                                            
                                            targetSession.isSignedIn = true
                                            targetSession.userName = user.profile?.name
                                            targetSession.emailAddress = user.profile?.email
                                            targetSession.profileImageURL = user.profile?.imageURL(withDimension: 100)?.absoluteString
                                            
                                            UserSession.shared = targetSession
                                            globalViewModel.session = User(email: targetSession.emailAddress ?? "", username: targetSession.userName ?? "", password: "Google Sign In", profilePicture: targetSession.profileImageURL ?? "")
                                            session = targetSession
                                        }
                                    }
                            }
                            .frame(width: 330, height: 50)
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .offset(y:-40)
                        .scaleEffect(secScale)
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 20){
                            Image(systemName: "apple.logo")
                                .resizable()
                                .frame(width: 30, height: 35)
                                .foregroundStyle(.black)
                            
                            Text("Sign in with Apple")
                                .font(.custom("ZohoPuvi-ExtraBold", size: 20))
                                .foregroundColor(.grayButton)
                        }
                        .frame(width: 330, height: 50)
                        
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(y:-20)
                    .scaleEffect(secScale)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .offset(y: height - slideInitial)
            .offset(y: -currentOffset > height - 380 ? -(height - 380) : currentOffset)
            .gesture(
                DragGesture()
                    .updating($gestureOffset) { value, out, _ in
                        out = value.translation.height
                        onChange()
                    }
                    .onEnded { _ in
                        showSheet()
                    }
            )
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                withAnimation(.easeOut(duration: 0.5)){
                    slideInitial = 380
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                for i in 0..<sentences.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.8)) {
                        withAnimation(.easeOut(duration: 1.2)) {
                            visibleCount += 1
                        }
                    }
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        scale = 1
                    }
                }
            }
        }
    }
    
    private func getRootViewController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return rootViewController
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.currentOffset = gestureOffset + lastOffset
        }
    }
    
    func showSheet() {
        withAnimation {
            let maxDrag = height - 380
            if (-currentOffset > maxDrag / 4 || slideSheet == true) {
                currentOffset = -maxDrag
                scale = 0
                infoOffset = -90
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation{
                        secScale = 1
                    }
                }
            } else {
                currentOffset = 0
                infoOffset = 60
                scale = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation{
                        secScale = 0
                    }
                }
            }
            
            lastOffset = currentOffset
            slideSheet = false
        }
    }
    
    
    func getBlurRadius() -> CGFloat {
        let progress = -currentOffset / (height - 380)
        return progress * 10
    }
}

struct Page: View {
    @State private var selectedTab = 0
    private let tabCount = 3
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OnboardView(imageName: "chart.bar.fill", title: "Charts", description: "Visualize real-time and historical crypto price trends with interactive charts.")
                .tag(0)
            
            OnboardView(imageName: "qrcode.viewfinder", title: "Scan QR", description: "Instantly scan QR codes to send or receive crypto payments, add wallet addresses.")
                .tag(1)
            
            OnboardView(imageName: "bubble.fill", title: "Chat", description: "Securely connect with your trade partner in real-time to discuss deals, negotiate prices.")
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .frame(width: width * 0.9, height: 400)
        .onAppear {
            startAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            withAnimation {
                selectedTab = (selectedTab + 1) % tabCount
            }
        }
    }
}


#Preview {
    Login()
        .modelContainer(for: UserSession.self)
}
