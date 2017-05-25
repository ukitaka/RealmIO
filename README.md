# RealmIO

`RealmIO` makes `Realm` type-safely and composable by using `reader monad`.

## Usage

`RealmIO<RW, T>` represents a realm action.

+ `RW` is actually `Read` or `Write`. It represents that action is readonly or not.
+ `T` is a return value type.

and you can also use `RealmRead<T>` and `RealmWrite<T>`, these are just alias of `RealmIO<Read, T>` and `RealmIO<Write, T>` .

```swift
public typealias RealmRead<T> = RealmIO<Read, T>

public typealias RealmWrite<T> = RealmIO<Write, T>
```

For example, action that reads `User` object from realm is typed `RealmRead<User>`.

```swift
func find(by userID: Int) -> RealmRead<User> {
    ...
}
```

TODO...
