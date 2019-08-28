# TinyKeychain
[![Travis CI](https://img.shields.io/travis/smolster/TinyKeychain/master.svg?style=flat-square)](https://travis-ci.org/smolster/TinyKeychain) [![code cov](https://img.shields.io/codecov/c/github/smolster/TinyKeychain.svg?style=flat-square)](https://codecov.io/gh/smolster/TinyKeychain) [![pod](https://img.shields.io/cocoapods/v/TinyKeychain.svg?style=flat-square)](https://cocoapods.org/pods/TinyKeychain) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage) ![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat-square) ![platforms](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat-square) [![license](	https://img.shields.io/github/license/smolster/TinyKeychain.svg?style=flat-square)](https://github.com/smolster/TinyKeychain/blob/master/LICENSE)

A Swifty, type-safe, easy-to-use keychain wrapper that can store anything that's `Codable`.

## How to use:

First, set up your objects.

TinyKeychain is built to store objects that are `Codable`, like this one:
```swift
struct MyToken: Codable {
    let fullToken: String
}
```

Create a `Keychain` instance. We recommend you create your instances as static properties on `Keychain`, so that they're accessible using Swift's dot syntax, like so:
```swift
extension Keychain {
    static let `default` = Keychain(group: "my.keychain.access.group")
}
```

The only way to store & retrieve objects to/from the keychain is using a `Keychain.Key` object. These are tied to a `Codable` object type, and also don't hold mutable state. We recommend you make them accessible using dot syntax, as well:
```swift
extension Keychain.Key {
    static var authToken: Keychain.Key<MyToken> {
        return Keychain.Key<MyToken>(rawValue: "auth.token.key", synchronize: true)
    }
}
```

Once you've got a `Keychain` instance, and a `Key` to query with, get to work! `Keychain` instances can be subscripted, like so:

```swift
// Store
Keychain.default[.authToken] = MyToken(fullToken: "sample.token")

// Retrieve
let fullToken = Keychain.default[.authToken]?.fullToken

// Delete
Keychain.default[.authToken] = nil
```

Or, you can use the full API, and implement some error handling:
```swift
// Store
let token = MyToken(fullToken: "sample.token")
switch Keychain.default.storeObject(token, forKey: .authToken) {
    case .success:
        print("Woohoo!")
    case .error(let error):
        print("Bummer! \(error.description)"
}

// Retrieve
switch Keychain.default.retrieveObject(forKey: .authToken) {
    case .success(let object):
        print("Woohoo! Token: \(object.fullToken)")
    case .error(let error):
        print("Bummer! \(error.description)")
}

// Delete
switch Keychain.default.deleteObject(forKey: .authToken) {
    case .success:
        print("Woohoo!")
    case .error(let error):
        print("Bummer! \(error.description)")
}
```
## Get it!
### CocoaPods
```ruby
pod 'TinyKeychain'
```
### Carthage
```
github 'smolster/TinyKeychain'
```
