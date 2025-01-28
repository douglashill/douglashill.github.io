date: 2024-12-30T12:24:01Z
%%%

iOS app sending emails cheatsheet:

- If you need **attachments**, use `MFMailComposeViewController`
- If you need **Mac Catalyst**, use `mailto` URLs
- If you need both **attachments and Mac Catalyst**, use `ShareLink`/`UIActivityViewController`
- If you don’t need either, pick one based on the UX

**Update:** [I wrote about this in more depth on our company blog](https://www.nutrient.io/blog/choosing-the-best-way-to-send-emails-in-an-ios-app/).
