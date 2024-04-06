date: 2024-02-23T11:25:51+0000
%%%

Lesson learned: While it’s fine to revoke a certificate used for app distribution at any time (you just make a new certificate), the same is not true when using the certificate to sign XCFrameworks, where revocation leads to not being able to build with already released versions.
