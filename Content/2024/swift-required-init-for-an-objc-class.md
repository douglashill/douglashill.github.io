date: 2024-07-31T12:36:26+02:00
%%%

To make a Swift `required` init for an ObjC class, put the init in a protocol:

```
@protocol PSPDFDocumentCreation <NSObject>

- (instancetype)initWithThing:(NSThing)thing;

@end

@interface PSPDFDocument: NSObject <PSPDFDocumentCreation>

@end
```

Thanks [Kostiantyn Herasimov for pointing this out](https://www.linkedin.com/feed/update/urn:li:activity:7218713440356327425?commentUrn=urn%3Ali%3Acomment%3A%28activity%3A7218713440356327425%2C7220056549921042432%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287220056549921042432%2Curn%3Ali%3Aactivity%3A7218713440356327425%29).
