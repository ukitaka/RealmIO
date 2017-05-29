
⚠️ This library is still under construction ⚠️

# RealmIO

`RealmIO` makes `Realm` operation more safely, reusable and composable by using `reader monad`.

## Motivation

Realm operations (especially `write` operations) is not reusable if you write a function as follows:

```swift
func addDog(name: String) throws {
    let realm = try Realm()
    try realm.write {
        let dog = Dog()
        dog.name = name
        realm.add(dog)
    }
}
``` 

At first glance, It works well, but actually there are some problems if you call this function multiple times.

```swift
addDog(name: "Taro")
addDog(name: "Jiro")
```

+ You cannot add 2 dog objects in a same transaction. In this case, `realm.write` is called twice.
+ Typically, to begin transaction is very slow, and `realm.write` locks realm instance.  We should not call `realm.write` needlessly.

![img](https://camo.githubusercontent.com/80325b8b7b367979e13528536fa036d5ef1c0d4f/68747470733a2f2f696d672e6573612e696f2f75706c6f6164732f70726f64756374696f6e2f6174746163686d656e74732f323234352f323031372f30352f32362f323838342f39343761326530392d343738662d343161622d616330302d3864663162393331383635612e706e67) ![img](https://camo.githubusercontent.com/3d48d89d7b463f885bb3ae39bfacf85c1851e174/68747470733a2f2f696d672e6573612e696f2f75706c6f6164732f70726f64756374696f6e2f6174746163686d656e74732f323234352f323031372f30352f32362f323838342f35663730353930362d393833622d343364312d396662622d3165303333616338336138392e706e67)

You can also write this function as follows:

```swift
func addDog(name: String, to realm: Realm) {
    let dog = Dog()
    dog.name = name
    realm.add(dog)
}
``` 

```swift
try realm.write {
    addDog(name: "Taro", to: realm)
    addDog(name: "Jiro", to: realm)
}
```

2 `addDog` calls will be run in a same transaction, but user needs to call `realm.write` by oneself. 
+ The user can not judge from the signature whether to begin a transaction by oneself.
+ It is sometimes painfully to pass `Realm` instance as argument explicitly.

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

