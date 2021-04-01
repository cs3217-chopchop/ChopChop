//
//  DocumentReference+combine.swift
//  ChopChop
//
//  Created by Cao Wenjie on 30/3/21.
//
import Combine
import Firebase

extension DocumentReference {
    var combine: CombineFIRDocument {
        CombineFIRDocument(document: self)
    }
}

struct CombineFIRDocument {
    fileprivate let document: DocumentReference
}

extension CombineFIRDocument {
    struct Publisher: Combine.Publisher {
        public typealias Output = DocumentSnapshot
        public typealias Failure = Error

        private let document: DocumentReference
        private let addListener: (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration
        private let removeListener: (ListenerRegistration) -> Void

        init(document: DocumentReference,
                addListener: @escaping (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration,
                removeListener: @escaping (ListenerRegistration) -> Void) {
            self.document = document
            self.addListener = addListener
            self.removeListener = removeListener
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            print("receive subscription")
            let subscription = Subscription(subscriber: subscriber,
                                            document: document,
                                            addListener: addListener,
                                            removeListener: removeListener)
            subscriber.receive(subscription: subscription)
        }
    }

}

extension CombineFIRDocument {
    public final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == DocumentSnapshot, S.Failure == Error {
        private var subscriber: S?
        private let document: DocumentReference
        private let _cancel: () -> Void

        fileprivate init(subscriber: S,
                         document: DocumentReference,
                         addListener: @escaping (DocumentReference, @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration,
                         removeListener: @escaping (ListenerRegistration) -> Void) {

            self.subscriber = subscriber
            self.document = document

            let listener = addListener(document) { documentSnapshot, error in
                print("receive document \(documentSnapshot)")
                if let error = error {
                    subscriber.receive(completion: .failure(error))
                } else if let documentSnapshot = documentSnapshot {
                    _ = subscriber.receive(documentSnapshot)
                }
            }
            self._cancel = {
                removeListener(listener)
            }
            print("end")
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            _cancel()
            subscriber = nil
        }

    }
}

extension CombineFIRDocument {
    public func snapshotPublisher() -> AnyPublisher<DocumentSnapshot, Error> {
        let a = Publisher(document: document, addListener: { $0.addSnapshotListener($1) }, removeListener: { $0.remove() })
            .eraseToAnyPublisher()
        print("done")
        return a
    }
}
