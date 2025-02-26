import SwiftUI
import SwiftMatrixSDK

struct EventContainerView: View {
    var event: MXEvent
    var reactions: [Reaction]
    var connectedEdges: ConnectedEdges
    var showSender: Bool
    var edits: [MXEvent]
    var contextMenuModel: EventContextMenuModel

    private var topPadding: CGFloat {
        connectedEdges.contains(.topEdge) ? 2.0 : 8.0
    }

    private var bottomPadding: CGFloat {
        connectedEdges.contains(.bottomEdge) ? 2.0 : 8.0
    }

    var body: some View {
        switch MXEventType(identifier: event.type) {
        case .roomMessage:
            guard !event.isRedactedEvent() else {
                let redactor = event.redactedBecause["sender"] as? String ?? L10n.Event.unknownSenderFallback
                let reason = (event.redactedBecause["content"] as? [AnyHashable: Any])?["body"] as? String
                return AnyView(
                    RedactionEventView(model: .init(sender: event.sender, redactor: redactor, reason: reason))
                )
            }

            guard !event.isEdit() else {
                return AnyView(EmptyView())
            }

            if event.isMediaAttachment() {
                return AnyView(
                    MediaEventView(model: .init(event: event, showSender: showSender))
                )
            }

            var newEvent = event
            if event.contentHasBeenEdited() {
                newEvent = edits.last ?? event
            }

            // FIXME: remove
            // swiftlint:disable:next force_try
            let messageModel = try! MessageViewModel(event: newEvent,
                                                     reactions: reactions,
                                                     showSender: showSender)
            return AnyView(
                MessageView(
                    model: .constant(messageModel),
                    contextMenuModel: contextMenuModel,
                    connectedEdges: connectedEdges,
                    isEdited: event.contentHasBeenEdited()
                )
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            )
        case .roomMember:
            return AnyView(
                RoomMemberEventView(model: .init(event: event))
            )
        case .roomTopic:
            return AnyView(
                RoomTopicEventView(model: .init(event: event))
            )
        case .roomPowerLevels:
            return AnyView(
                RoomPowerLevelsEventView(model: .init(event: event))
            )
        case .roomName:
            return AnyView(
                RoomNameEventView(model: .init(event: event))
            )
        default:
            return AnyView(
                GenericEventView(text: "\(event.type!)\n\(event.content!)")
                    .padding(.top, 10)
            )
        }
    }
}
