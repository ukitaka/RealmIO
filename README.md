# RealmIO

[![Build Status](https://travis-ci.org/ukitaka/RealmIO.svg?branch=master)](https://travis-ci.org/ukitaka/RealmIO)
[![codecov](https://codecov.io/gh/ukitaka/RealmIO/branch/master/graph/badge.svg)](https://codecov.io/gh/ukitaka/RealmIO)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![CocoaPods](https://img.shields.io/cocoapods/v/RealmIO.svg)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

+ `RW` is actually `ReadOnly` or `ReadWrite`. It represents that operation is readonly or not.
+ `T` is a return value type.

and you can also use `RealmRO<T>` and `RealmRW<T>`, these are just alias of `RealmIO<ReadOnly, T>` and `RealmIO<ReadWrite, T>` .

```swift
public typealias RealmRO<T> = RealmIO<ReadOnly, T>

public typealias RealmRW<T> = RealmIO<ReadWrite, T>
```

For example, operation that reads `User` object from realm is typed `RealmRO<User>`.

```swift
func find(by userID: Int) -> RealmRO<User> {
    ...
}
```

If you already know about `reader monad`, `RealmIO<RW, T>` is the same as `Reader<Realm, T>`, except for the `RW` type parameter.

### Run Realm operation with `realm.run(io:)`

You can run preceding realm operation with `realm.run(io:)`.

```swift
let io: RealmRO<User> = find(by: 123)
let result = try? realm.run(io: io)
```

If operation needs to write to realm (it means `io` is an instance of `RealmRW<T>`),
`realm.run(io:)` begins transaction automatically.

`realm.run(io:)` throws 2 error types.

+ `Realm.Error`
+ Error that thrown by user

### Compose realm operation with `flatMap`

`flatMap` allows you to compose realm actions.

```swift
func add(dog: Dog) -> RealmRW<Void> {
    ...
}

func add(cat: Cat) -> RealmRW<Void> {
    ...
}

let io: RealmRW<Void> = add(dog: myDog).flatMap { _ in add(cat: myCat) }
```

And you can run composed operation **in a same transaction**.

```swift
realm.run(io: io) // Add `myDog` and `myCat` in a same transaction.
```

`RW` type parameter of composed operation is determined by 2 operation types.
```swift
read.flatMap { _ in read }   // ReadOnly
read.flatMap { _ in write }  // ReadWrite
write.flatMap { _ in read }  // ReadWrite
write.flatMap { _ in write } // ReadWrite
```

### Use convenient operator

`Realm.IO` provides useful operators to create `RealmIO` instance.
See:  [Realm+Operator.swift](https://github.com/ukitaka/RealmIO/blob/master/Sources/Realm%2BOperator.swift)


### NOTE: Some of methods provided by `RealmIO` are not thread safe yet.

Some methods that takes `Object` as an argument such as `Realm.IO.add`, `Realm.IO.delete` are not thread safe for now. 
It is not better to pass `Object` directly. If you want to use this method safely, you should call `realm.run(io:)` in a same thread, or use with `flatMap`.

```swift
// OK: call `realm.run(io:)` in a same thread.
let io1 = Realm.IO.add(object)
try realm.run(io: io1)

// OK: use with `flatMap`
let io2 = Realm.IO.objects(Dog.self).flatMap(Realm.IO.delete)
try realm.run(io: io2)
```

Since `ThreadSafeReference` has a constraint that references can not be resolved within write transactions, implementation with `ThreadSafeReference` can not be done in 1.1. I'm considering measures after the next version.

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

+ Xcode 8.3
+ swift 3.1

`RealmIO` supports following platforms.

+ iOS 8.0+
+ macOS 10.10+
+ watchOS 2.0+
+ tvOS 9.0+

## Credits

`RealmIO` was inspired by [Slick](http://slick.lightbend.com/)'s `DBIOAction`.
