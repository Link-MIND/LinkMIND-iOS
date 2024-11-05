//
//  Publisher+UIBarButtonItem.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/29/24.
//

import Combine
import UIKit

extension UIBarButtonItem {
    func publisher() -> UIBarButtonItemPublisher<UIBarButtonItem> {
        UIBarButtonItemPublisher(item: self)
    }
}

final class UIBarButtonItemSubscription<S: Subscriber, Item: UIBarButtonItem>: Subscription where S.Input == Item {
    private var subscriber: S?
    private let item: Item
    
    init(subscriber: S, item: Item) {
        self.subscriber = subscriber
        self.item = item
        item.target = self
        item.action = #selector(eventHandler)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        subscriber = nil
    }
    
    @objc
    private func eventHandler() {
        _ = subscriber?.receive(item)
    }
}

public struct UIBarButtonItemPublisher<Item: UIBarButtonItem>: Publisher {
    public typealias Output = Item
    public typealias Failure = Never

    private let item: Item

    init(item: Item) {
        self.item = item
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == Self.Failure,
                                                S.Input == Self.Output {
        let subscription = UIBarButtonItemSubscription(
            subscriber: subscriber,
            item: item)
        subscriber.receive(subscription: subscription)
    }
}
