//
//  Publisher+UIGesture.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/29/24.
//

import Combine
import UIKit

extension UIView {
    func gesture(_ gestureType: GestureType) -> GesturePublisher {
        self.isUserInteractionEnabled = true
        return GesturePublisher(view: self, gestureType: gestureType)
    }
}

final class GestureSubscription<S: Subscriber>: Subscription where S.Input == GestureType {
    private var subscriber: S?
    private let gestureType: GestureType
    private var view: UIView
    
    init(subscriber: S, gestureType: GestureType, view: UIView) {
        self.subscriber = subscriber
        self.gestureType = gestureType
        self.view = view
        configureGesture(gestureType)
    }
    
    private func configureGesture(_ gestureType: GestureType) {
        let gesture = gestureType.get()
        gesture.addTarget(self, action: #selector(eventHandler))
        self.view.addGestureRecognizer(gesture)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        subscriber = nil
    }
    
    @objc
    private func eventHandler() {
        _ = subscriber?.receive(self.gestureType)
    }
}

public struct GesturePublisher: Publisher {
    public typealias Output = GestureType
    public typealias Failure = Never

    private let view: UIView
    private let gestureType: GestureType

    init(view: UIView, gestureType: GestureType) {
        self.view = view
        self.gestureType = gestureType
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber,
                                                S.Failure == GesturePublisher.Failure,
                                                S.Input == GesturePublisher.Output {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            gestureType: self.gestureType,
            view: self.view)
        subscriber.receive(subscription: subscription)
    }
}

public enum GestureType {
    case tap(UITapGestureRecognizer = .init())
    case swipe(UISwipeGestureRecognizer = .init())
    case longPress(UILongPressGestureRecognizer = .init())
    case pan(UIPanGestureRecognizer = .init())
    case pinch(UIPinchGestureRecognizer = .init())
    case edge(UIScreenEdgePanGestureRecognizer = .init())
    
    func get() -> UIGestureRecognizer {
        switch self {
        case let .tap(tapGesture): return tapGesture
        case let .swipe(swipeGesture):
            return swipeGesture
        case let .longPress(longPressGesture):
            return longPressGesture
        case let .pan(panGesture):
            return panGesture
        case let .pinch(pinchGesture):
            return pinchGesture
        case let .edge(edgePanGesture):
            return edgePanGesture
        }
    }
}
