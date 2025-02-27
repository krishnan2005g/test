import UIKit

class HistoryViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var history: [[String: Any]] = [
        ["Result": "420", "Expression": "400+20"],
        ["Result": "1000", "Expression": "500*2"],
        ["Result": "200", "Expression": "1000-800"],
        ["Result": "100", "Expression": "200/2"],
        ["Result": "300", "Expression": "100+200"],
        ["Result": "500", "Expression": "250*2"],
        ["Result": "350", "Expression": "100+250"],
        ["Result": "150", "Expression": "200-50"],
    ]
    
    private var selectedIndexPath: IndexPath?
    private let expandedCellHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    private let normalCellHeight: CGFloat = 90
    
    private lazy var tableView: UITableView = {
        let tableview = UITableView(frame: .zero, style: .insetGrouped)
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(HistoryCell.self, forCellReuseIdentifier: "cell")
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        let item = history[indexPath.row]
        
        guard let result = item["Result"] as? String,
              let expression = item["Expression"] as? String else {
            cell.configure(result: "Unknown Result", expression: "")
            return cell
        }
        
        cell.configure(result: result, expression: expression)
        cell.isExpanded = selectedIndexPath == indexPath
        cell.delegate = self
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedIndexPath == indexPath ? expandedCellHeight : normalCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            tableView.performBatchUpdates(nil)
        }
    }
    
    func deleteHistoryItem(at index: Int) {
        history.remove(at: index)
        tableView.reloadData()
    }
}

// MARK: - Custom Cell
class HistoryCell: UITableViewCell {
    weak var delegate: HistoryViewController2?
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expressionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let arrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let expandedContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isExpanded: Bool = false {
        didSet {
            expandedContentView.isHidden = !isExpanded
            UIView.animate(withDuration: 0.3) {
                self.arrowButton.transform = self.isExpanded ?
                    CGAffineTransform(rotationAngle: .pi/2) : .identity
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(resultLabel)
        containerView.addSubview(expressionLabel)
        containerView.addSubview(arrowButton)
        containerView.addSubview(expandedContentView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            resultLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            resultLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            expressionLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            expressionLabel.leadingAnchor.constraint(equalTo: resultLabel.leadingAnchor),
            
            arrowButton.centerYAnchor.constraint(equalTo: resultLabel.centerYAnchor),
            arrowButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            arrowButton.widthAnchor.constraint(equalToConstant: 30),
            arrowButton.heightAnchor.constraint(equalToConstant: 30),
            
            expandedContentView.topAnchor.constraint(equalTo: expressionLabel.bottomAnchor, constant: 16),
            expandedContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            expandedContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expandedContentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        arrowButton.addTarget(self, action: #selector(arrowTapped), for: .touchUpInside)
        expandedContentView.isHidden = true
        
        // Add some sample content to expanded view
        let detailsLabel = UILabel()
        detailsLabel.text = "Additional calculation details will appear here"
        detailsLabel.textAlignment = .center
        detailsLabel.numberOfLines = 0
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        expandedContentView.addSubview(detailsLabel)
        NSLayoutConstraint.activate([
            detailsLabel.centerXAnchor.constraint(equalTo: expandedContentView.centerXAnchor),
            detailsLabel.centerYAnchor.constraint(equalTo: expandedContentView.centerYAnchor),
            detailsLabel.leadingAnchor.constraint(equalTo: expandedContentView.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: expandedContentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(result: String, expression: String) {
        resultLabel.text = result
        expressionLabel.text = expression
    }
    
    @objc private func arrowTapped() {
        let alert = UIAlertController(title: "Deletion Alert",
                                      message: "Confirm deletion?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.deleteHistoryItem(at: self.tag)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        delegate?.present(alert, animated: true)
    }
}

#Preview {
    HistoryViewController2()
}



