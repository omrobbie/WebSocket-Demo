//
//  ViewController.swift
//  WebSocket Demo
//
//  Created by omrobbie on 28/03/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var connectionButton: UIButton!

    private var isConnected: Bool = false {
        didSet {
            statusLabel.text = isConnected ? "Connected" : "Disconnected"
            statusLabel.backgroundColor = isConnected ? .yellow : .red

            connectionButton.setTitle(
                isConnected ? "Connect" : "Disconnect",
                for: .normal
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func webSocketConnect() {
        isConnected = true
    }

    private func webSocketDisconnect() {
        isConnected = false
    }

    @IBAction func didConnectionButtonTapped(_ sender: Any) {
        if isConnected {
            webSocketDisconnect()
        } else {
            webSocketConnect()
        }
    }
}
