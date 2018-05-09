# TinyKeychain
A type-safe, easy-to-use keychain wrapper that can store anything that's `Codable`.

## Basic Usage:

First, set up your objects...
```swift
struct TokenObject: Codable {
    let fullToken: String
}

extension Keychain {
    static var `default`: Keychain {
        return Keychain(keychainAccessGroup: "my.keychain.access.group")
    }
}

extension Keychain.Key {
    static var authToken: Keychain.Key<TokenObject> {
        return Keychain.Key<TokenObject>(rawValue: "auth.token.key", synchronize: true)
    }
}
```

Then, get to work!

```swift
// Store
Keychain.default[.authToken] = TokenObject(fullToken: "sample.token")

// Retrieve
let fullToken = Keychain.default[.authToken]?.fullToken

// Delete
Keychain.default[.authToken] = nil
```

Or, interface directly, and implement some error handling!
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
