//
//  Publisher+UIControl.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/29/24.
//

import Combine
import UIKit

extension UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<UIControl> {
        UIControlPublisher(control: self, events: events)
    }
}

final class UIControlSubscription<S: Subscriber, Control: UIControl>: Subscription where S.Input == Control {
    private var subscriber: S?
    private let control: Control
    
    init(subscriber: S, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        subscriber = nil
    }
    
    @objc
    private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

public struct UIControlPublisher<Control: UIControl>: Publisher {
    public typealias Output = Control
    public typealias Failure = Never

    private let control: Control
    private let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == UIControlPublisher.Failure,
                                                S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(
            subscriber: subscriber,
            control: control,
            event: controlEvents
        )
        subscriber.receive(subscription: subscription)
    }
}
