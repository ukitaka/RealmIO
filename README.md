
⚠️ This library is still under construction ⚠️

# RealmIO

`RealmIO` makes `Realm` more safely, reusable and composable by using `reader monad`.

## Usage

### Define Realm operation as `RealmIO`

`RealmIO<RW, T>` represents a realm operation.

+ `RW` is actually `Read` or `Write`. It represents that operation is readonly or not.
+ `T` is a return value type.

and you can also use `RealmRead<T>` and `RealmWrite<T>`, these are just alias of `RealmIO<Read, T>` and `RealmIO<Write, T>` .

```swift
public typealias RealmRead<T> = RealmIO<Read, T>

public typealias RealmWrite<T> = RealmIO<Write, T>
```

For example, operation that reads `User` object from realm is typed `RealmRead<User>`.

```swift
func find(by userID: Int) -> RealmRead<User> {
    ...
}
```

### Run Realm operation with `realm.run(io:)`

You can run preceding realm operation with `realm.run(io:)`.

```swift
let io: RealmRead<User> = find(by: 123)
let result = try? realm.run(io: io)
```

If operation needs to write to realm (it means `io` is an instance of `RealmWrite<T>`),
`realm.run(io:)` begins transaction automatically.

### Compose realm operation with `flatMap`

`flatMap` allows you to compose realm actions.

```swift
func add(dog: Dog) -> RealmWrite<Void> {
    ...
}

func add(cat: Cat) -> RealmWrite<Void> {
    ...
}

let io: RealmWrite<Void> = add(dog: myDog).flatMap { _ in add(cat: myCat) }
```

And you can run composed operation **in a same transaction**.

```swift
realm.run(io: io) // Add `myDog` and `myCat` in a same transaction.
```

(TODO)


## Installation

### CocoaPods

```
pod 'RealmIO'
```

### Carthage

```
github "ukitaka/RealmIO"
```

## Requirements

`RealmIO` uses swift 3.1 functionality, so support only swift 3.1 now.
And also uses `TreadsafeReference` functionality, it requires `RealmSwift ~> v2.2.0`

+ Xcode 8.3
+ swift 3.1
+ RealmSwift v2.2.0 or later

`RealmIO` supports following platforms.

+ iOS 8.0+
+ macOS 10.10+
+ watchOS 2.0+
+ tvOS 9.0+

