# TinyKeychain
A Swifty, type-safe, easy-to-use keychain wrapper that can store anything that's `Codable`.

## Basic Usage:

First, set up your objects.

TinyKeychain is built to store objects that are `Codable`, like this one:
```swift
struct Token: Codable {
    let fullToken: String
}
```

Create a `Keychain` instance. `Keychain` instances don't hold mutable state, so we recommend you create your instances as `static` computed `var`s, so that they're accessible using Swift's dot syntax, like so:
```swift
extension Keychain {
    static var `default`: Keychain {
        return Keychain(keychainAccessGroup: "my.keychain.access.group")
    }
}
```

The only way to store & retrieve objects to/from the keychain is using a `Keychain.Key` object. These are tied to a `Codable` object type, and also don't hold mutable state. We recommend you make them accessible using dot syntax, as well:
```swift
extension Keychain.Key {
    static var authToken: Keychain.Key<TokenObject> {
        return Keychain.Key<TokenObject>(rawValue: "auth.token.key", synchronize: true)
    }
}
```

Once you've got a `Keychain` instance, and a `Key` to query with, get to work! `Keychain` instances can be subscripted, like so:

```swift
// Store
Keychain.default[.authToken] = TokenObject(fullToken: "sample.token")

// Retrieve
let fullToken = Keychain.default[.authToken]?.fullToken

// Delete
Keychain.default[.authToken] = nil
```

Or, you can interface directly, and implement some error handling:
```swift
// Store
let token = TokenObject(fullToken: "sample.token")
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
        print("Bummer! \(error.description")
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
