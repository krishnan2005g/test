import SwiftUI
import Combine
import Kingfisher

let preview = "john"

struct ChatListView: View {
    @State private var users: [User] = []
    @Namespace private var profileAnimation
    @State private var showNotification = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            UsersListView(profileAnimation: profileAnimation, onSelectUser: { user, _ in
                withAnimation{
                    AnyView(ChatView(toUser: user, profileAnimation: profileAnimation).modelContainer(for: MessageModel.self))
                }
            })
            .onChange(of: WebSocketManager.shared.messages) {
                withAnimation {
                    showNotification = true
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    HStack{
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                        Text("Chat")
                            .font(.custom("ZohoPuvi-SemiBold", size: 20))
                            .foregroundColor(.white)
                    }
                    .onTapGesture {pGesture in
                        dismiss()
                    }
                }
            }
        }
    }

}


#Preview {
    NavigationStack{
        ChatListView()
    }
}

