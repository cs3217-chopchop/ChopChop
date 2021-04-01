//
//  DocumentPublisher.swift
//  ChopChop
//
//  Created by Cao Wenjie on 31/3/21.
//

//import Combine
//import FirebaseFirestore
//
//extension Publishers {
//    struct DocumentPublisher: Publisher {
//
//        typealias Output = DocumentSnapshot
//        typealias Failure = Never
//
//        private var document: DocumentReference
//
//        init(document: DocumentReference) {
//            self.document = document
//        }
//
//        func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
//            let documentSubscription = DocumentSubscription(subscriber: subscriber, document: document)
//            subscriber.receive(subscription: documentSubscription)
//            debugPrint("hello")
//        }
//    }
//
//    class DocumentSubscription<S: Subscriber>: Subscription where S.Input == DocumentSnapshot, S.Failure == Never {
//        func request(_ demand: Subscribers.Demand) {}
//
//        func cancel() {
//            subscriber = nil
//            handler = nil
//        }
//
//        private var subscriber: S?
//        private var handler: ListenerRegistration?
//        private var document: DocumentReference
//
//        init(subscriber: S, document: DocumentReference) {
//            self.subscriber = subscriber
//            self.document = document
//            handler = document.addSnapshotListener { doc, _ in
//                if let doc = doc {
//                    print(doc)
//                    _ = subscriber.receive(doc)
//                    print("recived")
//                }
//            }
//        }
//    }
//}
//
//extension DocumentReference {
//    func publisher() -> AnyPublisher<DocumentSnapshot, Never> {
//        let a = Publishers.DocumentPublisher(document: self).eraseToAnyPublisher()
//        print("hehe")
//        return a
//    }
//}
