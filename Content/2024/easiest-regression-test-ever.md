date: 2024-07-24T18:12:30+02:00
%%%

Easiest regression test I’ve ever written for a real-world bug:

```
func testDefaultConfigurationsAreEqual() {
    XCTAssertEqual(PDFConfiguration(), PDFConfiguration())
}
```
