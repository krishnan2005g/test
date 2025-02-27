import UIKit

class ProfileHeaderView: UIView {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.getPuviFont("bold", 16)
        label.textColor = .white
        return label
    }()
    
//    private let emailLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
//        label.textColor = UIColor.white.withAlphaComponent(0.7)
//        return label
//    }()
    
    private let toProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile>"
        label.font = Fonts.getPuviFont("medium", 12)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    var tapAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addTapGesture()
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, toProfileLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        
        let containerStack = UIStackView(arrangedSubviews: [profileImageView, stackView])
        containerStack.axis = .horizontal
        containerStack.spacing = 10
        containerStack.alignment = .center
        
        addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc private func handleTap() {
        tapAction?() // Execute the closure when tapped
    }
    
    func configure(with name: String, imageURL: String) {
        nameLabel.text = name
        
        if let url = URL(string: imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
}

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Create the profile header view
        let profileHeaderView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        profileHeaderView.configure(
            with: "Osama Bin Laden",
            imageURL: "https://assets.editorial.aetnd.com/uploads/2009/12/islamic-extremist-osama-bin-laden.jpg"
        )
        
        // Add tap action
        profileHeaderView.tapAction = {
            self.profileTapped()
        }
        
        // Wrap it inside a UIBarButtonItem
        let profileBarButtonItem = UIBarButtonItem(customView: profileHeaderView)
        navigationItem.leftBarButtonItem = profileBarButtonItem
    }
    
    private func profileTapped() {
        print("Profile header tapped!")
//        navigationController?.pushViewController(ViewController2(), animated: true)
    }
}

#Preview {
    UINavigationController(rootViewController: ProfileViewController())
}

//class ViewController2: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .blue
//    }
//}
