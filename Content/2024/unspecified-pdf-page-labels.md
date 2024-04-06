title: Unspecified PDF page labels
description: We had a report of a fun bug today with a situation the PDF reference doesn’t specify how to handle.
date: 2024-01-18T16:21:23+0000
%%%

We had a report of a fun bug today with a situation the PDF reference doesn’t specify how to handle.

PDFs can use custom labels for each page. E.g. from page index x use roman numbers then from page index y use decimal numbers. These ranges run until another range is specified or you reach the end of the document. This is used for front matter etc. so the first page of the actual content can be page 1. The spec says you have to start specifying these labels at page index 0. Makes sense.

We had a report today where a customer sent in a document that didn’t specify any labels until index 3. This means each PDF reader has to make up how to label the first three pages. Here’s what happens:

- Acrobat acts like the first range starts at index 0 rather than 3 so gives these page labels: 1, 2, 3, 4, 5, 6
- Preview acts like there is an entry for index 0 using decimal numbering, so does: 1, 2, 3, 1, 2, 3
- We found what we do in PSPDFKit is the most ‘logical’ way to fill in the missing numbers: -2, -1, 0, 1, 2, 3 🤪
