//
//  CombineFIRCollection.swift
//  ChopChop
//
//  Created by Cao Wenjie on 30/3/21.
//

import Combine
import Firebase

extension Query {
    var combine: CombineQuery {
        CombineQuery(query: self)
    }
}

struct CombineQuery {
    fileprivate let query: Query
}

extension CombineQuery {
    struct Publisher: Combine.Publisher {
        public typealias Output = QuerySnapshot
        public typealias Failure = Error

        private let query: Query
        private let addListener: (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration
        private let removeListener: (ListenerRegistration) -> Void

        fileprivate init(query: Query,
                addListener: @escaping (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration,
                removeListener: @escaping (ListenerRegistration) -> Void) {
            self.query = query
            self.addListener = addListener
            self.removeListener = removeListener
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            query: query,
                                            addListener: addListener,
                                            removeListener: removeListener)
            subscriber.receive(subscription: subscription)
        }
    }

}

extension CombineQuery {
    public final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == QuerySnapshot, S.Failure == Error {
        private var subscriber: S?
        private let query: Query
        private let _cancel: () -> Void

        fileprivate init(subscriber: S,
                         query: Query,
                         addListener: @escaping (Query, @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration,
                         removeListener: @escaping (ListenerRegistration) -> Void) {

            self.subscriber = subscriber
            self.query = query

            let listener = addListener(query) { querySnapshot, error in
                if let error = error {
                    subscriber.receive(completion: .failure(error))
                } else if let querySnapshot = querySnapshot {
                    _ = subscriber.receive(querySnapshot)
                }
            }
            self._cancel = {
                removeListener(listener)
            }
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            _cancel()
            subscriber = nil
        }

    }
}

extension CombineQuery {
    public func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {

        Publisher(query: query,
                    addListener: { $0.addSnapshotListener($1) },
                    removeListener: { $0.remove() }
                ).eraseToAnyPublisher()
    }
}
