title: AI Assistant beta in PDF Viewer
description: We’ve [released an early preview of our new AI Assistant](), which uses Apple Intelligence to answer questions about PDF documents. This is using Apple’s Foundation Models, so documents and questions are processed on the device without being sent anywhere. [Try it on TestFlight](https://testflight.apple.com/join/6IMUtZ8n/).
date: 2025-10-16T16:43:36+01:00
%%%

At [Nutrient](https://www.nutrient.io/), we’ve released an early preview of our new AI Assistant, which uses Apple Intelligence to answer questions about PDF documents.

This is using Apple’s [Foundation Models](https://developer.apple.com/documentation/foundationmodels), so documents and questions are processed on the device without being sent anywhere. It’s designed to handle large documents, and a lot of engineering effort has gone into [handling the context window](https://developer.apple.com/documentation/Technotes/tn3193-managing-the-on-device-foundation-model-s-context-window) of the on-device model.

How to try AI Assistant:

1. Check you have **iOS 26** or later (iPad or iPhone)
2. Check **Apple Intelligence** is enabled in the Settings app
3. [Install PDF Viewer using TestFlight](https://testflight.apple.com/join/6IMUtZ8n/) (2025.12 or later)
4. Open a document
5. Tap the ‘sparkle’ button in the top toolbar on iPad or in the ••• menu on iPhone

We’d really like to hear feedback about AI Assistant. The easiest way is to is to tap the (i) button at the top of the AI Assistant screen then tap Send Feedback to send us an email.

Known limitations:

- Document processing happens each time AI Assistant is opened. This feature is designed to handle large documents, and we’re working to speed this up.
- Question and answer history are not saved after the AI Assistant screen is hidden. We'll add this soon.
- Follow up questions aren’t supported. Each question is answered separately without referring to previous messages.
- The feature is not available on Mac.
