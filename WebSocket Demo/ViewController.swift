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

    private var webSocket: URLSessionWebSocketTask?

    private var isConnected: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                statusLabel.text = isConnected ? "Connected" : "Disconnected"
                statusLabel.backgroundColor = isConnected ? .yellow : .red

                connectionButton.setTitle(
                    isConnected ? "Disconnect" : "Connect",
                    for: .normal
                )
            }
        }
    }

    private func openSession(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }

    private func closeSession() {
        webSocket?.cancel(
            with: .goingAway,
            reason: "You've Closed The Connection".data(using: .utf8)
        )
    }

    private func send() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.webSocket?.send(
                URLSessionWebSocketTask.Message.string("WebSocket Demo"),
                completionHandler: { error in
                    if error == nil {
                        self.send()
                    } else {
                        self.showMessage("Error sending message...")
                    }
                }
            )
        }

        DispatchQueue.global().asyncAfter(
            deadline: .now() + 3,
            execute: workItem
        )
    }

    private func receive() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.webSocket?.receive(completionHandler: { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        self.showMessage("Data received \(data)")

                    case .string(let string):
                        self.showMessage("String received \(string)")

                    default:
                        break
                    }

                case .failure(let error):
//                    self.showMessage("Error Receiving \(error)")
                    break
                }

                if self.isConnected {
                    self.receive()
                }
            })
        }

        DispatchQueue.global().asyncAfter(
            deadline: .now() + 1,
            execute: workItem
        )
    }

    private func showMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.messageTextView.text += message + "\n"

            let range = NSRange(
                location: self.messageTextView.text.count - 1,
                length: 0
            )
            self.messageTextView.scrollRangeToVisible(range)
        }
    }

    private func webSocketConnect() {
        openSession(urlString: "ws://172.18.136.92/poc-ws/ws/price-feed")
    }

    private func webSocketDisconnect() {
        closeSession()
    }

    @IBAction func didConnectionButtonTapped(_ sender: Any) {
        if isConnected {
            webSocketDisconnect()
        } else {
            webSocketConnect()
        }
    }
}

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        isConnected = true
        showMessage("Connect to server")
        receive()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        isConnected = false
        showMessage("Disconnect to server. Reason: \(String(describing: reason))\n")
    }
}
